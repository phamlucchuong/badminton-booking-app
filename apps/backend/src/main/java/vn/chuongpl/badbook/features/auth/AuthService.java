package vn.chuongpl.badbook.features.auth;


import com.nimbusds.jose.*;
import com.nimbusds.jose.crypto.MACSigner;
import com.nimbusds.jose.crypto.MACVerifier;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.SignedJWT;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.experimental.NonFinal;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.auth.dto.request.LoginRequest;
import vn.chuongpl.badbook.features.auth.dto.response.AuthResponse;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;

import java.text.ParseException;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Date;
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
    UserRepository userRepository;
    JwtBlacklistService jwtBlacklistService;

    public AuthResponse authenticated(LoginRequest request) {
        PasswordEncoder passwordEncoder = new BCryptPasswordEncoder(10);
        var user = userRepository.findByEmailAndDeletedFalse(request.getEmail())
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));

//        Restaurant restaurant = user.getRestaurant();
//        if (restaurant != null && !restaurant.getApproved()) {
//            throw new AppException(ErrorCode.RESTAURANT_UNAUTHENTICATED);
//        }

        boolean authenticated = passwordEncoder.matches(request.getPassword(), user.getPassword());
        if (!authenticated) {
            throw new AppException(ErrorCode.AUTHENTICATION_FAILED);
        }
        String token = generatedToken(user);
        return AuthResponse.builder()
                .token(token)
                .authenticated(authenticated)
                .build();
    }

    public boolean introspect(String token) throws JOSEException, ParseException {
        boolean isValid = true;
        try {
            verifySignedJWT(token);
        } catch (Exception e) {
            isValid = false;
        }
        return isValid;

    }

    public void logout(String token) throws JOSEException, ParseException {
        var signToken = verifySignedJWT(token);
        var jwtID = signToken.getJWTClaimsSet().getJWTID();
        var expriryDate = signToken.getJWTClaimsSet().getExpirationTime();

        long currentTimeMillis = System.currentTimeMillis();
        long diffInSeconds = expriryDate.getTime() - currentTimeMillis;
        if (diffInSeconds > 0) {
            jwtBlacklistService.addTokenToBlacklist(token, diffInSeconds);
        }
    }

    public SignedJWT verifySignedJWT(String token) throws JOSEException, ParseException {
        JWSVerifier jwsVerifier = new MACVerifier(SIGN_KEY);
        SignedJWT signedJWT = SignedJWT.parse(token);
        Date expriryDate = signedJWT.getJWTClaimsSet().getExpirationTime();
        var verified = signedJWT.verify(jwsVerifier);
        if (!verified && expriryDate.after(new Date())) {
            throw new AppException(ErrorCode.UNAUTHENTICATED);
        }
        return signedJWT;
    }

    private String generatedToken(User user) {
        JWSHeader jwsHeader = new JWSHeader(JWSAlgorithm.HS512);
        JWTClaimsSet jwtClaimsSet = new JWTClaimsSet.Builder()
                .subject(user.getId().toString())
                .issuer(user.getName())
                .issueTime(new Date())
                .expirationTime(new Date(
                        Instant.now().plus(1, ChronoUnit.HOURS).toEpochMilli()
                ))
                .jwtID(UUID.randomUUID().toString())
                .claim("scope", buildScope(user))
                .build();
        Payload payload = new Payload(jwtClaimsSet.toJSONObject());
        JWSObject jwsObject = new JWSObject(jwsHeader, payload);
        try {
            jwsObject.sign(new MACSigner(SIGN_KEY));
        } catch (Exception e) {
            log.debug("Không thể tạo token với lỗi = " + e.getMessage());
            throw new RuntimeException(e);
        }
        return jwsObject.serialize();
    }

    private String buildScope(User account) {
        StringJoiner jStringJoiner = new StringJoiner(" ");
        if (!CollectionUtils.isEmpty(account.getRoles())) {
            account.getRoles().forEach(role -> jStringJoiner.add(role.getName()));
        }
        return jStringJoiner.toString();
    }

}
