package com.caffora.backend;

import com.caffora.backend.dto.auth.RegisterRequest;
import com.caffora.backend.dto.review.ReviewRequest;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.http.MediaType.APPLICATION_JSON;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ReviewFlowIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void authenticatedCustomerCanReviewProductAndRatingAppearsInProductSummary() throws Exception {
        String registrationBody = mockMvc.perform(post("/api/auth/register")
                        .contentType(APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new RegisterRequest(
                                "Review Customer", "review.customer@example.com", "SecurePass123"))))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        String token = objectMapper.readTree(registrationBody).get("token").asText();

        String productsBody = mockMvc.perform(get("/api/products"))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();
        JsonNode firstProduct = objectMapper.readTree(productsBody).get(0);
        long productId = firstProduct.get("id").asLong();

        mockMvc.perform(post("/api/products/{productId}/reviews", productId)
                        .header("Authorization", "Bearer " + token)
                        .contentType(APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new ReviewRequest(5, "Excellent coffee."))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.rating").value(5))
                .andExpect(jsonPath("$.userName").value("Review Customer"));

        mockMvc.perform(post("/api/products/{productId}/reviews", productId)
                        .header("Authorization", "Bearer " + token)
                        .contentType(APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new ReviewRequest(6, "Invalid rating"))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.fieldErrors[0].field").value("rating"));

        mockMvc.perform(get("/api/products/{productId}/reviews", productId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].comment").value("Excellent coffee."));

        mockMvc.perform(get("/api/products/{productId}", productId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.averageRating").value(5.0))
                .andExpect(jsonPath("$.reviewCount").value(1))
                .andExpect(jsonPath("$.topReviews[0].comment").value("Excellent coffee."));
    }

    @Test
    void reviewSubmissionRequiresAuthentication() throws Exception {
        String productsBody = mockMvc.perform(get("/api/products"))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();
        long productId = objectMapper.readTree(productsBody).get(0).get("id").asLong();

        mockMvc.perform(post("/api/products/{productId}/reviews", productId)
                        .contentType(APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new ReviewRequest(6, "Too high"))))
                .andExpect(status().isUnauthorized());
    }
}
