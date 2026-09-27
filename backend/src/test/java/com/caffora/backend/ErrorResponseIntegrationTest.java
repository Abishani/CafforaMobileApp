package com.caffora.backend;

import com.caffora.backend.exception.ErrorResponse;
import com.caffora.backend.exception.GlobalExceptionHandler;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.ResponseEntity;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.http.MediaType.APPLICATION_JSON;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ErrorResponseIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private GlobalExceptionHandler handler;

    @Test
    void unexpectedErrorsReturnAGenericMessageWithoutInternals() {
        MockHttpServletRequest req = new MockHttpServletRequest("GET", "/api/anything");
        RuntimeException leaky = new RuntimeException(
                "could not execute statement [Duplicate entry] [insert into users (password_hash) values (?)]; SQL [n/a]");

        ResponseEntity<ErrorResponse> response = handler.handleGeneric(leaky, req);

        assertThat(response.getStatusCode().value()).isEqualTo(500);
        assertThat(response.getBody().message()).isEqualTo("An unexpected error occurred. Please try again later.");
        assertThat(response.getBody().message()).doesNotContain("SQL", "insert", "password");
    }

    @Test
    void malformedJsonIsA400WithoutParserDetails() throws Exception {
        mockMvc.perform(post("/api/auth/login").contentType(APPLICATION_JSON).content("{not json"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("The request body is missing or malformed"));
    }

    @Test
    void wrongPathVariableTypeIsA400() throws Exception {
        mockMvc.perform(get("/api/products/not-a-number"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Invalid value for parameter 'id'"));
    }

    @Test
    void existingErrorContractsAreUnchanged() throws Exception {
        // 404 from ResourceNotFoundException, 401 from the security entry point, 400 validation shape
        mockMvc.perform(get("/api/products/999999"))
                .andExpect(status().isNotFound());
        mockMvc.perform(post("/api/reviews").contentType(APPLICATION_JSON).content("{}"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.message").value("Authentication is required to access this resource"));
        mockMvc.perform(post("/api/auth/register").contentType(APPLICATION_JSON).content("{\"name\":\"\",\"email\":\"x\",\"password\":\"\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Validation failed for one or more fields"))
                .andExpect(jsonPath("$.fieldErrors").isArray());
    }
}
