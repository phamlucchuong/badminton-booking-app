package vn.chuongpl.badbook.configuration;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.oauth2.jwt.BadJwtException;
import org.springframework.test.util.ReflectionTestUtils;
import vn.chuongpl.badbook.features.auth.AuthService;

@ExtendWith(MockitoExtension.class)
class CustomerJwtDecoderTest {

    private static final String SIGN_KEY =
            "test-secret-key-for-unit-tests-must-be-at-least-64-bytes-long-123";

    @Mock
    private AuthService authService;

    @InjectMocks
    private CustomerJwtDecoder customerJwtDecoder;

    @Test
    void shouldThrowBadJwtExceptionWhenTokenIsInvalid() throws Exception {
        ReflectionTestUtils.setField(customerJwtDecoder, "SIGN_KEY", SIGN_KEY);
        when(authService.introspect("invalid-token")).thenReturn(false);

        assertThrows(BadJwtException.class, () -> customerJwtDecoder.decode("invalid-token"));
    }
}
