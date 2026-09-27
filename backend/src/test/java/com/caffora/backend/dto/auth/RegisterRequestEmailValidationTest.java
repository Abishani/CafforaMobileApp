package com.caffora.backend.dto.auth;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;

class RegisterRequestEmailValidationTest {

    private static jakarta.validation.ValidatorFactory factory;
    private static Validator validator;

    @BeforeAll
    static void setUp() {
        factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();
    }

    @AfterAll
    static void tearDown() {
        factory.close();
    }

    private Set<ConstraintViolation<RegisterRequest>> emailViolations(String email) {
        Set<ConstraintViolation<RegisterRequest>> all = validator.validate(new RegisterRequest("Helan", email, "SecurePass123"));
        all.removeIf(v -> !v.getPropertyPath().toString().equals("email"));
        return all;
    }

    @ParameterizedTest
    @ValueSource(strings = {
            "helan@gmail.com",
            "elena.woods@gmail.com",
            "first.last+cafe@example.co.uk",
            "user_name-1@sub.domain.org",
            "UPPER@EXAMPLE.COM",
            "a@b.io"
    })
    void acceptsNormalAddresses(String email) {
        assertThat(emailViolations(email)).isEmpty();
    }

    @ParameterizedTest
    @ValueSource(strings = {
            "helan@gmail",       // no domain suffix (was accepted by plain @Email)
            "helan@",            // no domain
            "@gmail.com",        // no local part
            "helan gmail.com",   // missing @
            "helan@gmail.com.",  // trailing dot
            "helan@.com",        // empty first domain label
            "helan@gmail..com",  // empty middle label
            "hel an@gmail.com",  // whitespace
            "helan@@gmail.com"   // two @
    })
    void rejectsMalformedAddresses(String email) {
        assertThat(emailViolations(email))
                .extracting(ConstraintViolation::getMessage)
                .contains("Email must be a valid address");
    }

    @ParameterizedTest
    @ValueSource(strings = {"", "   "})
    void rejectsBlank(String email) {
        assertThat(emailViolations(email))
                .extracting(ConstraintViolation::getMessage)
                .contains("Email is required");
    }

    @Test
    void rejectsNull() {
        assertThat(emailViolations(null))
                .extracting(ConstraintViolation::getMessage)
                .contains("Email is required");
    }

    @Test
    void loginStillAcceptsExistingDotlessAccountsFormat() {
        // Login deliberately keeps plain @Email so legacy accounts can still sign in.
        Set<ConstraintViolation<LoginRequest>> v = validator.validate(new LoginRequest("helan@gmail", "whatever1"));
        assertThat(v).isEmpty();
    }
}
