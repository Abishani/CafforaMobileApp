package com.caffora.backend.repo;

import com.caffora.backend.model.Review;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface ReviewRepo extends JpaRepository<Review, Long> {

    /** Highest rating first; newest first among equal ratings (id breaks exact timestamp ties). */
    @EntityGraph(attributePaths = "user")
    List<Review> findAllByOrderByRatingDescCreatedAtDescIdDesc();

    @EntityGraph(attributePaths = "user")
    List<Review> findAllByOrderByRatingDescCreatedAtDescIdDesc(Pageable pageable);

    @Query("select avg(r.rating) from Review r")
    Double averageRating();
}
