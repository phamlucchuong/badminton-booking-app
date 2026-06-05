package vn.chuongpl.badbook.features.user;

import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.features.user.dto.request.ChangePasswordRequest;
import vn.chuongpl.badbook.features.user.dto.request.UserProfileUpdateRequest;
import vn.chuongpl.badbook.features.user.dto.response.UserResponse;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    @PreAuthorize("hasRole('USER')")
    public ApiResponse<UserResponse> getMyProfile(@AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.<UserResponse>builder()
                .data(userService.getUserResponseById(jwt.getSubject()))
                .build();
    }

    @PutMapping("/me")
    @PreAuthorize("hasRole('USER')")
    public ApiResponse<UserResponse> updateMyProfile(@AuthenticationPrincipal Jwt jwt,
                                                     @RequestBody UserProfileUpdateRequest request) {
        return ApiResponse.<UserResponse>builder()
                .data(userService.updateUserProfile(jwt.getSubject(), request))
                .build();
    }

    @PutMapping("/me/password")
    @PreAuthorize("hasRole('USER')")
    public ApiResponse<Void> changePassword(@AuthenticationPrincipal Jwt jwt,
                                            @RequestBody ChangePasswordRequest request) {
        userService.changePassword(jwt.getSubject(), request);
        return ApiResponse.<Void>builder().build();
    }
}
