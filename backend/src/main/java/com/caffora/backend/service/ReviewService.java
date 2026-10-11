package com.caffora.backend.service;

import com.caffora.backend.dto.review.ReviewListResponse;
import com.caffora.backend.dto.review.ReviewRequest;
import com.caffora.backend.dto.review.ReviewResponse;
import com.caffora.backend.exception.BadRequestException;
import com.caffora.backend.model.Review;
import com.caffora.backend.model.User;
import com.caffora.backend.repo.ReviewRepo;
import com.caffora.backend.repo.UserRepo;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ReviewService {

    private final ReviewRepo reviewRepository;
    private final UserRepo userRepository;

    /** Public: reviews ordered by rating desc then newest first; {@code limit} null = all. */
    public ReviewListResponse list(Integer limit) {
        if (limit != null && limit < 1) {
            throw new BadRequestException("limit must be at least 1");
        }
        List<Review> reviews = limit == null
                ? reviewRepository.findAllByOrderByRatingDescCreatedAtDescIdDesc()
                : reviewRepository.findAllByOrderByRatingDescCreatedAtDescIdDesc(PageRequest.of(0, limit));
        Double avg = reviewRepository.averageRating();
        double averageRating = avg == null ? 0 : Math.round(avg * 10) / 10.0;
        return new ReviewListResponse(
                averageRating,
                reviewRepository.count(),
                reviews.stream().map(ReviewResponse::from).toList()
        );
    }

    @Transactional
    public ReviewResponse create(String userEmail, ReviewRequest request) {
        User user = userRepository.findByEmailIgnoreCase(userEmail)
                .orElseThrow(() -> new IllegalStateException("Authenticated user vanished mid-request"));
        Review review = Review.builder()
                .user(user)
                .rating(request.rating())
                .comment(request.comment().trim())
                .build();
        return ReviewResponse.from(reviewRepository.save(review));
    }
}
