package com.caffora.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.Check;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.Instant;

/** A customer review of the cafe. Written by an authenticated user; readable by everyone. */
@Entity
@Table(name = "reviews", indexes = {
        @Index(name = "idx_reviews_rating_created", columnList = "rating, created_at"),
        @Index(name = "idx_reviews_user_id", columnList = "user_id")
})
@Check(constraints = "rating BETWEEN 1 AND 5")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Review {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    /** 1–5 stars. */
    @Column(nullable = false)
    private int rating;

    @Column(name = "comment_text", nullable = false, length = 500)
    private String comment;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;
}
