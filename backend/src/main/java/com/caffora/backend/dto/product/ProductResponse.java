package com.caffora.backend.dto.product;

import com.caffora.backend.dto.review.ReviewResponse;
import com.caffora.backend.model.Product;
import com.caffora.backend.model.ProductStatus;

import java.math.BigDecimal;
import java.util.List;

public record ProductResponse(
        Long id,
        String name,
        String description,
        BigDecimal price,
        Long categoryId,
        String categoryName,
        Integer calories,
        String imageUrl,
        ProductStatus status,
        Double averageRating,
        Long reviewCount,
        List<ReviewResponse> topReviews
) {
    public static ProductResponse from(Product product, Double averageRating, long reviewCount,
                                       List<ReviewResponse> topReviews) {
        return new ProductResponse(
                product.getId(),
                product.getName(),
                product.getDescription(),
                product.getPrice(),
                product.getCategory() != null ? product.getCategory().getId() : null,
                product.getCategory() != null ? product.getCategory().getName() : null,
                product.getCalories(),
                product.getImageUrl(),
                product.getStatus(),
                averageRating != null ? averageRating : 0.0,
                reviewCount,
                topReviews
        );
    }
}
