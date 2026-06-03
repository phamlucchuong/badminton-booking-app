package vn.chuongpl.badbook.features.auth;

import java.text.ParseException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.nimbusds.jose.JOSEException;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.features.auth.dto.request.LoginRequest;
import vn.chuongpl.badbook.features.auth.dto.request.RegisterRequest;
import vn.chuongpl.badbook.features.auth.dto.response.AuthResponse;
import vn.chuongpl.badbook.features.user.UserService;
import vn.chuongpl.badbook.features.user.dto.response.UserResponse;

@RestController
@RequestMapping("/api/auth")

public class AuthController {
    @Autowired
    AuthService authService;

    @Autowired
    UserService userService;

    @PostMapping
    public ApiResponse<AuthResponse> authenticated(@RequestBody LoginRequest request) {
        return ApiResponse.<AuthResponse>builder()
                .data(authService.authenticated(request))
                .build();
    }

    @PostMapping("/register")
    public ApiResponse<UserResponse> register(@RequestBody RegisterRequest request) {
        return ApiResponse.<UserResponse>builder()
                .data(userService.register(request))
                .message("Đăng ký thành công")
                .build();
    }

//    @PostMapping("/introspect")
//    public ApiResponse<IntrospectResponse> authenticate(@RequestBody IntrospectRequest request)
//            throws ParseException, JOSEException {
//        return ApiResponse.<IntrospectResponse>builder()
//                .results(authenticationService.introspect(request))
//                .build();
//    }

    @PostMapping("/logout")
    public ApiResponse<Void> logout(@AuthenticationPrincipal Jwt jwt) throws ParseException, JOSEException {
        String token = jwt.getTokenValue();
        authService.logout(token);
        return ApiResponse.<Void>builder()
                .message("Logout successfully")
                .build();
    }

}
