package vn.chuongpl.badbook.features.auth;

import com.nimbusds.jose.JOSEException;
import com.nimbusds.jose.JWSAlgorithm;
import com.nimbusds.jose.JWSHeader;
import com.nimbusds.jose.JWSObject;
import com.nimbusds.jose.JWSVerifier;
import com.nimbusds.jose.Payload;
import com.nimbusds.jose.crypto.MACSigner;
import com.nimbusds.jose.crypto.MACVerifier;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.SignedJWT;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.experimental.NonFinal;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.auth.dto.request.LoginRequest;
import vn.chuongpl.badbook.features.auth.dto.response.AuthResponse;
import vn.chuongpl.badbook.features.role.Role;
import vn.chuongpl.badbook.features.role.RoleRepository;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;

import java.nio.charset.StandardCharsets;
import java.text.ParseException;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Date;
import java.util.Map;
import java.util.Set;
import java.util.StringJoiner;
import java.util.UUID;

@Service
@Slf4j
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AuthService {
    @NonFinal
    @Value("${JWT_SECRET}")
    protected String SIGN_KEY;

    @NonFinal
    @Value("${google.client-id}")
    String googleClientId;

    UserRepository userRepository;
    RoleRepository roleRepository;
    JwtBlacklistService jwtBlacklistService;
    WebClient googleWebClient;

    public AuthResponse authenticated(LoginRequest request) {
        PasswordEncoder passwordEncoder = new BCryptPasswordEncoder(10);
        User user = userRepository.findByEmailAndDeletedFalse(request.getEmail())
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));

        if (user.getPassword() == null || !passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new AppException(ErrorCode.AUTHENTICATION_FAILED);
        }

        String accessToken = generatedToken(user, "access", 30);
        String refreshToken = generatedToken(user, "refresh", 7 * 24 * 60L);
        return AuthResponse.builder()
                .token(accessToken)
                .refreshToken(refreshToken)
                .authenticated(true)
                .build();
    }

    @SuppressWarnings("unchecked")
    public AuthResponse loginWithGoogle(String idToken) {
        Map<String, Object> tokenInfo;
        try {
            tokenInfo = googleWebClient.get()
                    .uri(uriBuilder -> uriBuilder
                            .path("/tokeninfo")
                            .queryParam("id_token", idToken)
                            .build())
                    .retrieve()
                    .bodyToMono(Map.class)
                    .block();
        } catch (WebClientResponseException exception) {
            throw new AppException(ErrorCode.GOOGLE_TOKEN_INVALID);
        }

        if (tokenInfo == null) {
            throw new AppException(ErrorCode.GOOGLE_TOKEN_INVALID);
        }

        String aud = (String) tokenInfo.get("aud");
        if (googleClientId == null || googleClientId.isBlank() || !googleClientId.equals(aud)) {
            throw new AppException(ErrorCode.GOOGLE_TOKEN_AUDIENCE_MISMATCH);
        }

        String sub = (String) tokenInfo.get("sub");
        String email = (String) tokenInfo.get("email");
        String name = (String) tokenInfo.getOrDefault("name", email);
        if (sub == null || email == null || email.isBlank()) {
            throw new AppException(ErrorCode.GOOGLE_TOKEN_INVALID);
        }

        User user = userRepository.findByEmailAndDeletedFalse(email).orElse(null);
        if (user == null) {
            Role userRole = roleRepository.findByName("USER")
                    .orElseThrow(() -> new AppException(ErrorCode.ROLE_NOT_FOUND));
            user = User.builder()
                    .name(name)
                    .email(email)
                    .googleId(sub)
                    .roles(Set.of(userRole))
                    .build();
            user = userRepository.save(user);
        } else if (user.getGoogleId() == null) {
            user.setGoogleId(sub);
            user = userRepository.save(user);
        }

        String accessToken = generatedToken(user, "access", 30);
        String refreshToken = generatedToken(user, "refresh", 7 * 24 * 60L);
        return AuthResponse.builder()
                .token(accessToken)
                .refreshToken(refreshToken)
                .authenticated(true)
                .build();
    }

    public boolean introspect(String token) throws JOSEException, ParseException {
        try {
            verifySignedJWT(token);
            return !jwtBlacklistService.isBlacklisted(token);
        } catch (Exception e) {
            return false;
        }
    }

    public void logout(String accessToken, String refreshToken) throws JOSEException, ParseException {
        SignedJWT signedAccessToken = verifySignedJWT(accessToken);
        Date accessExpiry = signedAccessToken.getJWTClaimsSet().getExpirationTime();
        long accessDiff = (accessExpiry.getTime() - System.currentTimeMillis()) / 1000;
        if (accessDiff > 0) {
            jwtBlacklistService.addTokenToBlacklist(accessToken, accessDiff);
        }

        if (refreshToken != null && !refreshToken.isBlank()) {
            try {
                SignedJWT signedRefreshToken = verifySignedJWT(refreshToken);
                Date refreshExpiry = signedRefreshToken.getJWTClaimsSet().getExpirationTime();
                long refreshDiff = (refreshExpiry.getTime() - System.currentTimeMillis()) / 1000;
                if (refreshDiff > 0) {
                    jwtBlacklistService.addTokenToBlacklist(refreshToken, refreshDiff);
                }
            } catch (Exception e) {
                log.warn("Could not blacklist refresh token: {}", e.getMessage());
            }
        }
    }

    public AuthResponse refreshAccessToken(String refreshToken) throws JOSEException, ParseException {
        SignedJWT signedJWT;
        try {
            signedJWT = verifySignedJWT(refreshToken);
        } catch (AppException exception) {
            throw new AppException(ErrorCode.INVALID_TOKEN);
        }

        String tokenType = (String) signedJWT.getJWTClaimsSet().getClaim("tokenType");
        if (!"refresh".equals(tokenType) || jwtBlacklistService.isBlacklisted(refreshToken)) {
            throw new AppException(ErrorCode.INVALID_TOKEN);
        }

        String userId = signedJWT.getJWTClaimsSet().getSubject();
        User user = userRepository.findById(UUID.fromString(userId))
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
        return AuthResponse.builder()
                .token(generatedToken(user, "access", 30))
                .authenticated(true)
                .build();
    }

    public SignedJWT verifySignedJWT(String token) throws JOSEException, ParseException {
        JWSVerifier jwsVerifier = new MACVerifier(signingKeyBytes());
        SignedJWT signedJWT = SignedJWT.parse(token);
        Date expiryDate = signedJWT.getJWTClaimsSet().getExpirationTime();
        boolean verified = signedJWT.verify(jwsVerifier);
        if (!verified || expiryDate.before(new Date())) {
            throw new AppException(ErrorCode.UNAUTHENTICATED);
        }
        return signedJWT;
    }

    private String generatedToken(User user, String tokenType, long ttlMinutes) {
        JWSHeader jwsHeader = new JWSHeader(JWSAlgorithm.HS512);
        JWTClaimsSet jwtClaimsSet = new JWTClaimsSet.Builder()
                .subject(user.getId().toString())
                .issuer(user.getName())
                .issueTime(new Date())
                .expirationTime(new Date(
                        Instant.now().plus(ttlMinutes, ChronoUnit.MINUTES).toEpochMilli()
                ))
                .jwtID(UUID.randomUUID().toString())
                .claim("scope", buildScope(user))
                .claim("tokenType", tokenType)
                .build();
        Payload payload = new Payload(jwtClaimsSet.toJSONObject());
        JWSObject jwsObject = new JWSObject(jwsHeader, payload);
        try {
            jwsObject.sign(new MACSigner(signingKeyBytes()));
        } catch (Exception e) {
            log.debug("Không thể tạo token với lỗi = {}", e.getMessage());
            throw new RuntimeException(e);
        }
        return jwsObject.serialize();
    }

    private String buildScope(User account) {
        StringJoiner joiner = new StringJoiner(" ");
        if (!CollectionUtils.isEmpty(account.getRoles())) {
            account.getRoles().forEach(role -> joiner.add(role.getName()));
        }
        return joiner.toString();
    }

    private byte[] signingKeyBytes() {
        byte[] keyBytes = SIGN_KEY.getBytes(StandardCharsets.UTF_8);
        if (keyBytes.length < 64) {
            throw new IllegalStateException("JWT_SECRET must be at least 64 bytes for HS512");
        }
        return keyBytes;
    }
}
