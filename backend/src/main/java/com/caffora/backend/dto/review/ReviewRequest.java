package com.caffora.backend.dto.review;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/** The author is always the authenticated user — never taken from the request body. */
public record ReviewRequest(
        @NotNull(message = "Please select a rating")
        @Min(value = 1, message = "Rating must be between 1 and 5")
        @Max(value = 5, message = "Rating must be between 1 and 5")
        Integer rating,

        @NotBlank(message = "Please enter your review")
        @Size(max = 500, message = "Review must be at most 500 characters")
        String comment
) {
}
