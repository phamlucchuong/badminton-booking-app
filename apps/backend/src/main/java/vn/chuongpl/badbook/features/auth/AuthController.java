package vn.chuongpl.badbook.features.auth;

import java.text.ParseException;

import com.nimbusds.jose.JOSEException;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.auth.dto.request.GoogleLoginRequest;
import vn.chuongpl.badbook.features.auth.dto.request.LoginRequest;
import vn.chuongpl.badbook.features.auth.dto.request.LogoutRequest;
import vn.chuongpl.badbook.features.auth.dto.request.RefreshTokenRequest;
import vn.chuongpl.badbook.features.auth.dto.request.RegisterRequest;
import vn.chuongpl.badbook.features.auth.dto.request.ResetPasswordRequest;
import vn.chuongpl.badbook.features.auth.dto.response.AuthResponse;
import vn.chuongpl.badbook.features.otp.OtpService;
import vn.chuongpl.badbook.features.user.UserService;
import vn.chuongpl.badbook.features.user.dto.response.UserResponse;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    AuthService authService;

    @Autowired
    UserService userService;

    @Autowired
    OtpService otpService;

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

    @PostMapping("/logout")
    public ApiResponse<Void> logout(@AuthenticationPrincipal Jwt jwt,
                                    @RequestBody(required = false) LogoutRequest request)
            throws ParseException, JOSEException {
        authService.logout(jwt.getTokenValue(), request != null ? request.getRefreshToken() : null);
        return ApiResponse.<Void>builder()
                .message("Logout successfully")
                .build();
    }

    @PostMapping("/refresh")
    public ApiResponse<AuthResponse> refresh(@RequestBody RefreshTokenRequest request)
            throws ParseException, JOSEException {
        return ApiResponse.<AuthResponse>builder()
                .data(authService.refreshAccessToken(request.getRefreshToken()))
                .build();
    }

    @PostMapping("/reset-password")
    public ApiResponse<Void> resetPassword(@RequestBody ResetPasswordRequest request) {
        boolean valid = otpService.validateOtp(request.getEmail(), request.getOtp());
        if (!valid) {
            throw new AppException(ErrorCode.OTP_INVALID);
        }
        userService.resetPassword(request.getEmail(), request.getNewPassword());
        return ApiResponse.<Void>builder()
                .message("Đặt lại mật khẩu thành công")
                .build();
    }

    @PostMapping("/google")
    public ApiResponse<AuthResponse> loginWithGoogle(@RequestBody @Valid GoogleLoginRequest request) {
        return ApiResponse.<AuthResponse>builder()
                .data(authService.loginWithGoogle(request.getIdToken()))
                .build();
    }
}
