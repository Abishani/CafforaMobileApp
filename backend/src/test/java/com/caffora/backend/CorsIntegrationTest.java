package com.caffora.backend;

import com.caffora.backend.config.CorsProperties;
import com.caffora.backend.config.SecurityConfig;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.options;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class CorsIntegrationTest {

    private static final String PRODUCTION_VALUE =
            "http://localhost:5173,https://caffora.vercel.app,https://caffora-*.vercel.app";

    /** The exact value intended for Railway (plus localhost), set through the real env-var binding. */
    @Nested
    @SpringBootTest(properties = "CORS_ALLOWED_ORIGINS=" + PRODUCTION_VALUE)
    @AutoConfigureMockMvc
    @ActiveProfiles("test")
    class WithProductionOrigins {

        @Autowired
        private MockMvc mockMvc;

        @ParameterizedTest
        @ValueSource(strings = {
                "http://localhost:5173",
                "https://caffora.vercel.app",
                "https://caffora-git-caffora-development-team.vercel.app",
                "https://caffora-8f3k2x9ab-team.vercel.app"
        })
        void preflightForAuthenticatedJsonPostIsAllowed(String origin) throws Exception {
            mockMvc.perform(options("/api/orders")
                            .header("Origin", origin)
                            .header("Access-Control-Request-Method", "POST")
                            .header("Access-Control-Request-Headers", "authorization,content-type"))
                    .andExpect(status().isOk())
                    .andExpect(header().string("Access-Control-Allow-Origin", origin))
                    .andExpect(header().string("Access-Control-Allow-Credentials", "true"))
                    .andExpect(header().string("Access-Control-Allow-Methods", org.hamcrest.Matchers.containsString("POST")))
                    .andExpect(header().string("Access-Control-Allow-Headers", org.hamcrest.Matchers.containsStringIgnoringCase("authorization")));
        }

        @Test
        void preflightForAdminPatchIsAllowed() throws Exception {
            mockMvc.perform(options("/api/orders/1/status")
                            .header("Origin", "https://caffora.vercel.app")
                            .header("Access-Control-Request-Method", "PATCH")
                            .header("Access-Control-Request-Headers", "authorization,content-type"))
                    .andExpect(status().isOk())
                    .andExpect(header().string("Access-Control-Allow-Origin", "https://caffora.vercel.app"));
        }

        @ParameterizedTest
        @ValueSource(strings = {
                "https://evil.example.com",
                "http://caffora.vercel.app",                // plain http
                "https://caffora-x.vercel.app.evil.com",    // suffix attack
                "https://notcaffora.vercel.app",
                "http://localhost:3001"
        })
        void otherOriginsAreRejected(String origin) throws Exception {
            mockMvc.perform(options("/api/orders")
                            .header("Origin", origin)
                            .header("Access-Control-Request-Method", "POST"))
                    .andExpect(status().isForbidden())
                    .andExpect(header().doesNotExist("Access-Control-Allow-Origin"));
        }

        @Test
        void actualRequestsCarryCorsHeadersAndAuthIsStillEnforced() throws Exception {
            // Public endpoint: allowed origin gets the CORS headers.
            mockMvc.perform(get("/api/products").header("Origin", "https://caffora.vercel.app"))
                    .andExpect(status().isOk())
                    .andExpect(header().string("Access-Control-Allow-Origin", "https://caffora.vercel.app"))
                    .andExpect(header().string("Access-Control-Allow-Credentials", "true"));

            // CORS does not bypass authentication: protected endpoint without a token is still 401.
            mockMvc.perform(get("/api/orders/my").header("Origin", "https://caffora.vercel.app"))
                    .andExpect(status().isUnauthorized());
        }
    }

    /** Default (no CORS_ALLOWED_ORIGINS set): local development origins keep working. */
    @Nested
    @SpringBootTest
    @AutoConfigureMockMvc
    @ActiveProfiles("test")
    class WithDefaultLocalOrigins {

        @Autowired
        private MockMvc mockMvc;

        @ParameterizedTest
        @ValueSource(strings = {"http://localhost:5173", "http://localhost:3000"})
        void localDevOriginsAreAllowed(String origin) throws Exception {
            mockMvc.perform(options("/api/auth/login")
                            .header("Origin", origin)
                            .header("Access-Control-Request-Method", "POST")
                            .header("Access-Control-Request-Headers", "content-type"))
                    .andExpect(status().isOk())
                    .andExpect(header().string("Access-Control-Allow-Origin", origin));
        }

        @Test
        void productionOriginIsNotAllowedLocallyByDefault() throws Exception {
            mockMvc.perform(options("/api/auth/login")
                            .header("Origin", "https://caffora.vercel.app")
                            .header("Access-Control-Request-Method", "POST"))
                    .andExpect(status().isForbidden());
        }
    }

    /** A credentialed wildcard must never be accepted. */
    @Nested
    class WildcardGuard {

        @ParameterizedTest
        @ValueSource(strings = {"*", " * ", "https://*", "http://*"})
        void wildcardOriginsAreRefused(String bad) {
            SecurityConfig config = new SecurityConfig(null, null, null, new CorsProperties(List.of("https://caffora.vercel.app", bad)));
            assertThatThrownBy(config::corsConfigurationSource)
                    .isInstanceOf(IllegalStateException.class)
                    .hasMessageContaining("CORS_ALLOWED_ORIGINS");
        }

        @Test
        void emptyOriginListIsRefused() {
            SecurityConfig config = new SecurityConfig(null, null, null, new CorsProperties(List.of()));
            assertThatThrownBy(config::corsConfigurationSource).isInstanceOf(IllegalStateException.class);
        }
    }
}
