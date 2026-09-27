package com.caffora.backend.config;

import org.springframework.boot.diagnostics.AbstractFailureAnalyzer;
import org.springframework.boot.diagnostics.FailureAnalysis;

/** Turns {@link MissingRequiredSecretsException} into Spring Boot's readable "APPLICATION FAILED TO START" report. */
public class MissingRequiredSecretsFailureAnalyzer extends AbstractFailureAnalyzer<MissingRequiredSecretsException> {

    @Override
    protected FailureAnalysis analyze(Throwable rootFailure, MissingRequiredSecretsException cause) {
        String description = "Caffora cannot start because required secrets are missing or invalid:\n  - "
                + String.join("\n  - ", cause.getProblems());
        String action = "Set the listed environment variables. Locally, add them to backend/.env "
                + "(see backend/.env.example) and run docker compose. On Railway, add them under the "
                + "backend service's Variables tab (see backend/RAILWAY.md).";
        return new FailureAnalysis(description, action, cause);
    }
}
