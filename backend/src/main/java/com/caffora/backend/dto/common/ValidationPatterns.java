package com.caffora.backend.dto.common;

/** Shared regular expressions for request validation. */
public final class ValidationPatterns {

    private ValidationPatterns() {
    }

    /**
     * local@domain.tld: no whitespace, exactly one '@', and a domain of two or more non-empty
     * dot-separated labels (so "helan@gmail" and "helan@.com" are rejected). Used together with
     * {@code @Email}, which still applies its RFC checks. Mirrors EMAIL_PATTERN in the web app's AuthPage.
     */
    public static final String EMAIL = "^[^\\s@]+@[^\\s@.]+(\\.[^\\s@.]+)+$";
}
