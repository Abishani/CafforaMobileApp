package com.caffora.backend;

import com.caffora.backend.dto.auth.RegisterRequest;
import com.caffora.backend.repo.ReviewRepo;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.http.MediaType.APPLICATION_JSON;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ReviewIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private ReviewRepo reviewRepo;

    @BeforeEach
    void clearReviews() {
        reviewRepo.deleteAll();
    }

    private String registerAndGetToken(String name) throws Exception {
        String email = "reviewer-" + UUID.randomUUID() + "@example.com";
        String body = mockMvc.perform(post("/api/auth/register")
                        .contentType(APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new RegisterRequest(name, email, "SecurePass123"))))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        return objectMapper.readTree(body).get("token").asText();
    }

    private void postReview(String token, int rating, String comment) throws Exception {
        mockMvc.perform(post("/api/reviews")
                        .header("Authorization", "Bearer " + token)
                        .contentType(APPLICATION_JSON)
                        .content("{\"rating\":" + rating + ",\"comment\":" + objectMapper.writeValueAsString(comment) + "}"))
                .andExpect(status().isCreated());
    }

    @Test
    void guestCanReadButNotPost() throws Exception {
        mockMvc.perform(get("/api/reviews"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalCount").value(0))
                .andExpect(jsonPath("$.reviews").isArray());

        mockMvc.perform(post("/api/reviews")
                        .contentType(APPLICATION_JSON)
                        .content("{\"rating\":5,\"comment\":\"Sneaky guest review\"}"))
                .andExpect(status().isUnauthorized());

        assertThat(reviewRepo.count()).isZero();
    }

    @Test
    void authenticatedUserPostsReviewAsThemselves() throws Exception {
        String token = registerAndGetToken("Helan");

        // A userId in the body is ignored: the author always comes from the JWT.
        mockMvc.perform(post("/api/reviews")
                        .header("Authorization", "Bearer " + token)
                        .contentType(APPLICATION_JSON)
                        .content("{\"rating\":5,\"comment\":\"  Really good coffee and very fast service.  \",\"userId\":999}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.reviewerName").value("Helan"))
                .andExpect(jsonPath("$.rating").value(5))
                .andExpect(jsonPath("$.comment").value("Really good coffee and very fast service."))
                .andExpect(jsonPath("$.createdAt").exists())
                .andExpect(jsonPath("$.email").doesNotExist())
                .andExpect(jsonPath("$.user").doesNotExist());

        mockMvc.perform(get("/api/reviews"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalCount").value(1))
                .andExpect(jsonPath("$.averageRating").value(5.0))
                .andExpect(jsonPath("$.reviews[0].reviewerName").value("Helan"))
                .andExpect(jsonPath("$.reviews[0].email").doesNotExist());
    }

    @Test
    void validationRejectsMissingRatingBlankTextAndOutOfRange() throws Exception {
        String token = registerAndGetToken("Validator");

        mockMvc.perform(post("/api/reviews")
                        .header("Authorization", "Bearer " + token)
                        .contentType(APPLICATION_JSON)
                        .content("{\"comment\":\"No rating here\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.fieldErrors[0].field").value("rating"));

        mockMvc.perform(post("/api/reviews")
                        .header("Authorization", "Bearer " + token)
                        .contentType(APPLICATION_JSON)
                        .content("{\"rating\":4,\"comment\":\"   \"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.fieldErrors[0].field").value("comment"));

        mockMvc.perform(post("/api/reviews")
                        .header("Authorization", "Bearer " + token)
                        .contentType(APPLICATION_JSON)
                        .content("{\"rating\":6,\"comment\":\"Too many stars\"}"))
                .andExpect(status().isBadRequest());

        assertThat(reviewRepo.count()).isZero();
    }

    @Test
    void reviewsAreSortedByRatingThenNewestAndLimitReturnsTopN() throws Exception {
        String token = registerAndGetToken("Sorter");
        postReview(token, 3, "three");
        postReview(token, 5, "five-older");
        postReview(token, 4, "four");
        postReview(token, 5, "five-newer");
        postReview(token, 1, "one");
        postReview(token, 2, "two");
        postReview(token, 4, "four-newer");

        String all = mockMvc.perform(get("/api/reviews"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalCount").value(7))
                .andReturn().getResponse().getContentAsString();
        JsonNode reviews = objectMapper.readTree(all).get("reviews");
        assertThat(reviews).hasSize(7);
        assertThat(reviews.findValuesAsText("comment"))
                .containsExactly("five-newer", "five-older", "four-newer", "four", "three", "two", "one");

        mockMvc.perform(get("/api/reviews").param("limit", "5"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalCount").value(7))
                .andExpect(jsonPath("$.averageRating").value(3.4))
                .andExpect(jsonPath("$.reviews.length()").value(5))
                .andExpect(jsonPath("$.reviews[4].comment").value("three"));

        mockMvc.perform(get("/api/reviews").param("limit", "0"))
                .andExpect(status().isBadRequest());
    }
}
