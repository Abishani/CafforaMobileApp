package com.caffora.backend.service;

import com.caffora.backend.dto.review.ReviewRequest;
import com.caffora.backend.dto.review.ReviewResponse;
import com.caffora.backend.exception.ResourceNotFoundException;
import com.caffora.backend.model.Product;
import com.caffora.backend.model.Review;
import com.caffora.backend.model.User;
import com.caffora.backend.repo.ProductRepo;
import com.caffora.backend.repo.ReviewRepo;
import com.caffora.backend.repo.UserRepo;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ReviewService {

    private final ReviewRepo reviewRepository;
    private final ProductRepo productRepository;
    private final UserRepo userRepository;

    public List<ReviewResponse> listForProduct(Long productId) {
        requireProduct(productId);
        return reviewRepository.findByProductIdOrderByCreatedAtDesc(productId).stream()
                .map(ReviewResponse::from)
                .toList();
    }

    @Transactional
    public ReviewResponse addOrUpdate(Long productId, String userEmail, ReviewRequest request) {
        Product product = requireProduct(productId);
        User user = userRepository.findByEmailIgnoreCase(userEmail)
                .orElseThrow(() -> new IllegalStateException("Authenticated user vanished mid-request"));

        Review review = reviewRepository.findByProductIdAndUserId(productId, user.getId())
                .orElseGet(() -> Review.builder().product(product).user(user).build());
        review.setRating(request.rating());
        review.setComment(request.comment().trim());
        return ReviewResponse.from(reviewRepository.save(review));
    }

    private Product requireProduct(Long productId) {
        return productRepository.findById(productId)
                .orElseThrow(() -> ResourceNotFoundException.of("Product", productId));
    }
}
