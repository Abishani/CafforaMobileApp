package com.caffora.backend.config;

import org.junit.jupiter.api.Test;
import org.springframework.boot.SpringApplication;
import org.springframework.mock.env.MockEnvironment;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.catchThrowableOfType;

class RequiredSecretsValidatorTest {

    private static final String VALID_JWT = "dGVzdC1vbmx5LWp3dC1zZWNyZXQtbm90LXVzZWQtYW55d2hlcmUtZWxzZQ==";

    private final RequiredSecretsValidator validator = new RequiredSecretsValidator();

    private MockEnvironment env(String dbPassword, String jwtSecret, String adminPassword) {
        MockEnvironment env = new MockEnvironment();
        if (dbPassword != null) env.setProperty("spring.datasource.password", dbPassword);
        if (jwtSecret != null) env.setProperty("caffora.jwt.secret", jwtSecret);
        if (adminPassword != null) env.setProperty("caffora.admin.seed-password", adminPassword);
        return env;
    }

    @Test
    void acceptsValidSecrets() {
        assertThatCode(() -> validator.postProcessEnvironment(env("db-pass", VALID_JWT, "AdminPass1"), new SpringApplication()))
                .doesNotThrowAnyException();
    }

    @Test
    void acceptsEmptyDatabasePasswordWhenExplicitlySet() {
        // e.g. the in-memory H2 database used by the test profile
        assertThatCode(() -> validator.postProcessEnvironment(env("", VALID_JWT, "AdminPass1"), new SpringApplication()))
                .doesNotThrowAnyException();
    }

    @Test
    void rejectsUnresolvedPlaceholdersInsteadOfUsingThemAsValues() {
        MockEnvironment env = env("${DB_PASSWORD}", "${JWT_SECRET}", "${ADMIN_SEED_PASSWORD}");

        MissingRequiredSecretsException ex = catchThrowableOfType(
                () -> validator.postProcessEnvironment(env, new SpringApplication()),
                MissingRequiredSecretsException.class);

        assertThat(ex).isNotNull();
        assertThat(ex.getProblems()).hasSize(3);
        assertThat(ex.getMessage()).contains("DB_PASSWORD", "JWT_SECRET", "ADMIN_SEED_PASSWORD");
    }

    @Test
    void rejectsMissingBlankAndTooShortValues() {
        MissingRequiredSecretsException ex = catchThrowableOfType(
                () -> validator.postProcessEnvironment(env(null, "too-short", "   "), new SpringApplication()),
                MissingRequiredSecretsException.class);

        assertThat(ex.getProblems()).anySatisfy(p -> assertThat(p).startsWith("DB_PASSWORD is not set"));
        assertThat(ex.getProblems()).anySatisfy(p -> assertThat(p).startsWith("JWT_SECRET must be at least"));
        assertThat(ex.getProblems()).anySatisfy(p -> assertThat(p).startsWith("ADMIN_SEED_PASSWORD is not set"));
    }

    @Test
    void neverIncludesSecretValuesInTheMessage() {
        MissingRequiredSecretsException ex = catchThrowableOfType(
                () -> validator.postProcessEnvironment(env("db-pass", "short-secret-value", "abc"), new SpringApplication()),
                MissingRequiredSecretsException.class);

        assertThat(ex.getMessage()).doesNotContain("short-secret-value", "db-pass", "abc\"");
    }
}
