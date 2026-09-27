package com.caffora.backend.controller;

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

import java.util.List;

@RestController
@RequestMapping("/api/products/{productId}/reviews")
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewService reviewService;

    @GetMapping
    public ResponseEntity<List<ReviewResponse>> list(@PathVariable Long productId) {
        return ResponseEntity.ok(reviewService.listForProduct(productId));
    }

    @PostMapping
    public ResponseEntity<ReviewResponse> addOrUpdate(
            @PathVariable Long productId,
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody ReviewRequest request
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(reviewService.addOrUpdate(productId, principal.getUsername(), request));
    }
}
