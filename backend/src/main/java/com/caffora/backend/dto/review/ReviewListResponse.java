package com.caffora.backend.dto.review;

import java.util.List;

/**
 * Reviews sorted by rating desc, then newest first. {@code totalCount} and {@code averageRating}
 * always describe every review, even when {@code reviews} is limited to the top N.
 */
public record ReviewListResponse(
        double averageRating,
        long totalCount,
        List<ReviewResponse> reviews
) {
}
