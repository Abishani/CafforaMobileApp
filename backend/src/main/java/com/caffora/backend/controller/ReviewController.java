package com.caffora.backend.controller;

import com.caffora.backend.dto.review.ReviewListResponse;
import com.caffora.backend.dto.review.ReviewRequest;
import com.caffora.backend.dto.review.ReviewResponse;
import com.caffora.backend.security.UserPrincipal;
import com.caffora.backend.service.ReviewService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/reviews")
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewService reviewService;

    /** Public: reviews sorted by rating desc, newest first; pass {@code limit} for the top N only. */
    @GetMapping
    public ResponseEntity<ReviewListResponse> list(@RequestParam(name = "limit", required = false) Integer limit) {
        return ResponseEntity.ok(reviewService.list(limit));
    }

    /** Any signed-in user (customer or admin): post a review as themselves. */
    @PostMapping
    public ResponseEntity<ReviewResponse> create(@AuthenticationPrincipal UserPrincipal principal,
                                                 @Valid @RequestBody ReviewRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(reviewService.create(principal.getUsername(), request));
    }
}
