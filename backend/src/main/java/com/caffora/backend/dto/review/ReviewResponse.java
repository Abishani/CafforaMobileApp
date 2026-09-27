package com.caffora.backend.dto.review;

import com.caffora.backend.model.Review;

import java.time.Instant;

public record ReviewResponse(
        Long id,
        Long productId,
        Long userId,
        String userName,
        Integer rating,
        String comment,
        Instant createdAt,
        Instant updatedAt
) {
    public static ReviewResponse from(Review review) {
        return new ReviewResponse(
                review.getId(),
                review.getProduct().getId(),
                review.getUser().getId(),
                review.getUser().getName(),
                review.getRating(),
                review.getComment(),
                review.getCreatedAt(),
                review.getUpdatedAt()
        );
    }
}
