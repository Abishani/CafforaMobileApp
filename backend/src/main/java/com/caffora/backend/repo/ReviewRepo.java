package com.caffora.backend.repo;

import com.caffora.backend.model.Review;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ReviewRepo extends JpaRepository<Review, Long> {

    List<Review> findTop5ByProductIdOrderByCreatedAtDesc(Long productId);

    List<Review> findByProductIdOrderByCreatedAtDesc(Long productId);

    Optional<Review> findByProductIdAndUserId(Long productId, Long userId);

    long countByProductId(Long productId);

    @Query("select avg(r.rating) from Review r where r.product.id = :productId")
    Double averageRatingByProductId(@Param("productId") Long productId);
}
