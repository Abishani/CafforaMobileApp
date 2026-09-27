package com.caffora.backend.config;

import java.util.List;

/** Thrown at startup by {@link RequiredSecretsValidator}; lists problems only, never secret values. */
public class MissingRequiredSecretsException extends IllegalStateException {

    private final List<String> problems;

    public MissingRequiredSecretsException(List<String> problems) {
        super("Required secrets are missing or invalid: " + String.join("; ", problems));
        this.problems = List.copyOf(problems);
    }

    public List<String> getProblems() {
        return problems;
    }
}
