package com.caffora.backend.dto.review;

import com.caffora.backend.model.Review;

import java.time.Instant;

/** Public view of a review: exposes only the reviewer's display name, never email/role/credentials. */
public record ReviewResponse(
        Long id,
        String reviewerName,
        int rating,
        String comment,
        Instant createdAt
) {
    public static ReviewResponse from(Review review) {
        return new ReviewResponse(
                review.getId(),
                review.getUser().getName(),
                review.getRating(),
                review.getComment(),
                review.getCreatedAt()
        );
    }
}
