package vn.chuongpl.badbook.configuration;

import java.nio.charset.StandardCharsets;
import java.text.ParseException;
import java.util.Objects;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtException;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.stereotype.Component;
import com.nimbusds.jose.JOSEException;
import vn.chuongpl.badbook.features.auth.AuthService;

@Component
public class CustomerJwtDecoder implements JwtDecoder {

    @Value("${JWT_SECRET}")
    private String SIGN_KEY;

    @Autowired
    AuthService authService;

    private NimbusJwtDecoder nimbusJwtDecoder = null;
    @Override
    public Jwt decode(String token){
        try {
            var response = authService.introspect(token);
            if(!response) {
                throw new JwtException("Token invalid");
            }
        } catch (JOSEException | ParseException e) {
            throw new JwtException(e.getMessage());
        }

        if(Objects.isNull(nimbusJwtDecoder)){
            SecretKeySpec secretKey = new SecretKeySpec(signingKeyBytes(), "HS512");
            nimbusJwtDecoder = NimbusJwtDecoder.withSecretKey(secretKey)
                    .macAlgorithm(MacAlgorithm.HS512)
                    .build();
        }
        return nimbusJwtDecoder.decode(token);
    }

    private byte[] signingKeyBytes() {
        byte[] keyBytes = SIGN_KEY.getBytes(StandardCharsets.UTF_8);
        if (keyBytes.length < 64) {
            throw new JwtException("JWT_SECRET must be at least 64 bytes for HS512");
        }
        return keyBytes;
    }
}
