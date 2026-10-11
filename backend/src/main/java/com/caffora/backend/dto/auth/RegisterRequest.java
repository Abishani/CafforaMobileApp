package com.caffora.backend.dto.auth;

import com.caffora.backend.dto.common.ValidationPatterns;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RegisterRequest(
        @NotBlank(message = "Name is required")
        @Size(max = 120, message = "Name must be at most 120 characters")
        String name,

        @NotBlank(message = "Email is required")
        // Stricter than plain @Email, which accepts dot-less domains like "helan@gmail".
        // Login keeps plain @Email so existing accounts are never locked out.
        @Email(regexp = ValidationPatterns.EMAIL, message = "Email must be a valid address")
        String email,

        @NotBlank(message = "Password is required")
        @Size(min = 8, max = 100, message = "Password must be between 8 and 100 characters")
        String password
) {
}
