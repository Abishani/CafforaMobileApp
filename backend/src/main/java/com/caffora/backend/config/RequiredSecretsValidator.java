package com.caffora.backend.config;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.env.EnvironmentPostProcessor;
import org.springframework.core.Ordered;
import org.springframework.core.env.ConfigurableEnvironment;

import java.util.ArrayList;
import java.util.List;

/**
 * Fails startup with a clear message when a required secret is missing, instead of letting Spring
 * bind the literal placeholder text (e.g. an admin password of "${ADMIN_SEED_PASSWORD}").
 *
 * application.yml deliberately has no fallbacks for these values; they must come from the
 * environment (Railway variables, or backend/.env via docker-compose locally). The test profile
 * supplies its own values in application-test.yml.
 *
 * Runs after the config files are loaded but before any bean is created. Registered in
 * META-INF/spring.factories. Never logs or echoes secret values.
 */
public class RequiredSecretsValidator implements EnvironmentPostProcessor, Ordered {

    static final int JWT_SECRET_MIN_LENGTH = 32;
    static final int ADMIN_PASSWORD_MIN_LENGTH = 8;

    @Override
    public void postProcessEnvironment(ConfigurableEnvironment environment, SpringApplication application) {
        List<String> problems = new ArrayList<>();

        // May legitimately be empty (e.g. an in-memory H2 database), but must be defined.
        String dbPassword = resolve(environment, "spring.datasource.password");
        if (dbPassword == null) {
            problems.add("DB_PASSWORD is not set (spring.datasource.password)");
        }

        String jwtSecret = resolve(environment, "caffora.jwt.secret");
        if (jwtSecret == null || jwtSecret.isBlank()) {
            problems.add("JWT_SECRET is not set (caffora.jwt.secret)");
        } else if (jwtSecret.length() < JWT_SECRET_MIN_LENGTH) {
            problems.add("JWT_SECRET must be at least " + JWT_SECRET_MIN_LENGTH
                    + " characters (e.g. generate one with: openssl rand -base64 48)");
        }

        String adminPassword = resolve(environment, "caffora.admin.seed-password");
        if (adminPassword == null || adminPassword.isBlank()) {
            problems.add("ADMIN_SEED_PASSWORD is not set (caffora.admin.seed-password)");
        } else if (adminPassword.length() < ADMIN_PASSWORD_MIN_LENGTH) {
            problems.add("ADMIN_SEED_PASSWORD must be at least " + ADMIN_PASSWORD_MIN_LENGTH + " characters");
        }

        if (!problems.isEmpty()) {
            throw new MissingRequiredSecretsException(problems);
        }
    }

    /** Returns the resolved value, or null if the key is absent or references an unset variable. */
    private static String resolve(ConfigurableEnvironment environment, String key) {
        try {
            return environment.getProperty(key);
        } catch (IllegalArgumentException unresolvedPlaceholder) {
            return null;
        }
    }

    @Override
    public int getOrder() {
        // After ConfigDataEnvironmentPostProcessor has loaded application.yml and profile files.
        return Ordered.LOWEST_PRECEDENCE;
    }
}
