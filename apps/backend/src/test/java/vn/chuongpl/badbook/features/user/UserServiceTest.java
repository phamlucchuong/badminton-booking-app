package vn.chuongpl.badbook.features.user;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.role.RoleRepository;
import vn.chuongpl.badbook.features.user.dto.request.ChangePasswordRequest;
import vn.chuongpl.badbook.features.user.dto.request.UserProfileUpdateRequest;
import vn.chuongpl.badbook.features.user.dto.response.UserResponse;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock UserRepository userRepository;
    @Mock PasswordEncoder passwordEncoder;
    @Mock UserMapper userMapper;
    @Mock RoleRepository roleRepository;
    @InjectMocks UserService userService;

    @Test
    void changePassword_throwsInvalidPassword_whenCurrentPasswordIsWrong() {
        String userId = UUID.randomUUID().toString();
        User user = User.builder().id(UUID.fromString(userId)).password("encoded").build();
        ChangePasswordRequest request = new ChangePasswordRequest("wrong", "newPass123");

        when(userRepository.findById(any(UUID.class))).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("wrong", "encoded")).thenReturn(false);

        assertThatThrownBy(() -> userService.changePassword(userId, request))
                .isInstanceOf(AppException.class)
                .extracting("errorCode").isEqualTo(ErrorCode.INVALID_PASSWORD);
    }

    @Test
    void changePassword_encodesAndSavesNewPassword_whenCurrentPasswordIsCorrect() {
        String userId = UUID.randomUUID().toString();
        User user = User.builder().id(UUID.fromString(userId)).password("encoded").build();
        ChangePasswordRequest request = new ChangePasswordRequest("correct", "newPass123");

        when(userRepository.findById(any(UUID.class))).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("correct", "encoded")).thenReturn(true);
        when(passwordEncoder.encode("newPass123")).thenReturn("newEncoded");
        when(userRepository.save(any(User.class))).thenReturn(user);

        userService.changePassword(userId, request);

        verify(passwordEncoder).encode("newPass123");
        verify(userRepository).save(argThat(savedUser -> "newEncoded".equals(savedUser.getPassword())));
    }

    @Test
    void resetPassword_encodesAndSavesNewPassword() {
        String email = "user@example.com";
        User user = User.builder().email(email).password("old-encoded").build();

        when(userRepository.findByEmailAndDeletedFalse(email)).thenReturn(Optional.of(user));
        when(passwordEncoder.encode("newPass123")).thenReturn("new-encoded");
        when(userRepository.save(any(User.class))).thenReturn(user);

        userService.resetPassword(email, "newPass123");

        verify(passwordEncoder).encode("newPass123");
        verify(userRepository).save(argThat(savedUser -> "new-encoded".equals(savedUser.getPassword())));
    }

    @Test
    void resetPassword_throwsAccountNotFound_whenEmailDoesNotExist() {
        when(userRepository.findByEmailAndDeletedFalse("missing@example.com"))
                .thenReturn(Optional.empty());

        assertThatThrownBy(() -> userService.resetPassword("missing@example.com", "newPass"))
                .isInstanceOf(AppException.class)
                .extracting("errorCode").isEqualTo(ErrorCode.ACCOUNT_NOT_FOUND);
    }

    @Test
    void updateUserProfile_updatesNameAndPhone() {
        String userId = UUID.randomUUID().toString();
        User user = User.builder().id(UUID.fromString(userId)).name("Old").phone("000").build();
        UserProfileUpdateRequest request = new UserProfileUpdateRequest("New Name", "111");
        UserResponse response = UserResponse.builder().name("New Name").build();

        when(userRepository.findById(any(UUID.class))).thenReturn(Optional.of(user));
        when(userRepository.save(any(User.class))).thenReturn(user);
        when(userMapper.toUserResponse(any(User.class))).thenReturn(response);

        UserResponse result = userService.updateUserProfile(userId, request);

        verify(userRepository).save(argThat(savedUser ->
                "New Name".equals(savedUser.getName()) && "111".equals(savedUser.getPhone())));
        assertThat(result.getName()).isEqualTo("New Name");
    }
}
