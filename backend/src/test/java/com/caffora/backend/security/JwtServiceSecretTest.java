package com.caffora.backend.security;

import com.caffora.backend.model.Role;
import com.caffora.backend.model.User;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import static org.assertj.core.api.Assertions.assertThat;

class JwtServiceSecretTest {

    private static UserPrincipal principal() {
        return new UserPrincipal(User.builder()
                .id(1L).name("Test").email("jwt.test@example.com").passwordHash("x").role(Role.CUSTOMER).build());
    }

    @ParameterizedTest
    @ValueSource(strings = {
            // standard base64 (what `openssl rand -base64 48` produces)
            "dGVzdC1vbmx5LWp3dC1zZWNyZXQtbm90LXVzZWQtYW55d2hlcmUtZWxzZQ==",
            // base64url alphabet ('-' and '_'): previously crashed startup with DecodingException
            "ab-cd_ef-gh_ij-kl_mn-op_qr-st_uv-wx_yz-01_23",
            // plain passphrase
            "a plain passphrase that is definitely long enough!"
    })
    void acceptsAnySecretFormatAndIssuesVerifiableTokens(String secret) {
        JwtService jwt = new JwtService(new JwtProperties(secret, 3_600_000L, "caffora-test"));
        UserPrincipal user = principal();

        String token = jwt.generateToken(user);

        assertThat(jwt.extractEmail(token)).isEqualTo("jwt.test@example.com");
        assertThat(jwt.isTokenValid(token, user)).isTrue();
    }

    @Test
    void standardBase64SecretStillDecodesToTheSameKey() {
        // Tokens signed before this change must still validate: same secret -> same key.
        String secret = "dGVzdC1vbmx5LWp3dC1zZWNyZXQtbm90LXVzZWQtYW55d2hlcmUtZWxzZQ==";
        String token = new JwtService(new JwtProperties(secret, 3_600_000L, "caffora-test")).generateToken(principal());

        assertThat(new JwtService(new JwtProperties(secret, 3_600_000L, "caffora-test")).isTokenValid(token, principal())).isTrue();
    }
}
