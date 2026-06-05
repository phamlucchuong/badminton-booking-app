package vn.chuongpl.badbook.features.user;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.PageResponse;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.enums.Role;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.auth.dto.request.RegisterRequest;
import vn.chuongpl.badbook.features.role.RoleRepository;
import vn.chuongpl.badbook.features.user.dto.request.ChangePasswordRequest;
import vn.chuongpl.badbook.features.user.dto.request.UserCreateRequest;
import vn.chuongpl.badbook.features.user.dto.request.UserProfileUpdateRequest;
import vn.chuongpl.badbook.features.user.dto.request.UserUpdateRequest;
import vn.chuongpl.badbook.features.user.dto.response.UserResponse;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = lombok.AccessLevel.PRIVATE, makeFinal = true)
public class UserService {
    UserRepository userRepository;
    PasswordEncoder passwordEncoder;
    UserMapper userMapper;
    RoleRepository roleRepository;

    public UserResponse register(RegisterRequest request) {
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new AppException(ErrorCode.EMAIL_EXISTED);
        }
        var userRole = roleRepository.findById("USER")
                .orElseThrow(() -> new AppException(ErrorCode.ROLE_NOT_FOUND));
        var roles = new HashSet<>(Set.of(userRole));
        User user = User.builder()
                .name(request.getName())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .phone(request.getPhone())
                .roles(roles)
                .createdAt(LocalDateTime.now())
                .build();
        return userMapper.toUserResponse(userRepository.save(user));
    }

    protected User getUserById(String id) {
        return userRepository.findById(parseUuid(id))
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
    }

    boolean existById(String id) {
        return userRepository.existsById(parseUuid(id));
    }

    public UserResponse createUser(UserCreateRequest request) {
        if (!verifyEmail(request.getEmail())) {
            throw new AppException(ErrorCode.EMAIL_EXISTED);
        }
        User user = userMapper.toUser(request);
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setCreatedAt(LocalDateTime.now());
        return userMapper.toUserResponse(userRepository.save(user));
    }

    public Boolean verifyEmail(String emailRequest) {
        Optional<User> user = userRepository.findByEmailAndDeletedFalse(emailRequest);
        return user.isEmpty();
    }

    public UserResponse updateUser(String email, UserUpdateRequest request) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
        userMapper.toUpdate(user, request);
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        return userMapper.toUserResponse(userRepository.save(user));
    }

    public PageResponse<UserResponse> getAllUser(Integer page) {
        int limit = 2;
        int pageCurrent = page != null && page > 0 ? page - 1 : 0;
        Pageable pageable = PageRequest.of(pageCurrent, limit, Sort.by(Sort.Direction.DESC, "name"));
        List<String> roles = List.of(Role.USER.name(),
                Role.VENUE_MANAGER.name(),
                Role.ADMIN.name());
        Page<User> users = userRepository.findByRolesIn(roles, pageable);

        return PageResponse.<UserResponse>builder()
                .items(users.getContent().stream().map(userMapper::toUserResponse).toList())
                .total(users.getTotalElements())
                .page(pageCurrent + 1)
                .pageSize(limit)
                .totalPages(users.getTotalPages())
                .build();
    }

    public void deleteUser(String id) {
        User user = userRepository.findByIdAndDeletedFalse(parseUuid(id))
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
        user.setDeleted(!user.isDeleted());
        userRepository.save(user);
    }

    public User getUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
    }

    public UserResponse getUserResponseById(String id) {
        if (id == null || id.isEmpty()) {
            throw new AppException(ErrorCode.ACCOUNT_NOT_FOUND);
        }
        User user = userRepository.findById(parseUuid(id))
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
        return userMapper.toUserResponse(user);
    }

    public UserResponse updateUserProfile(String userId, UserProfileUpdateRequest request) {
        User user = userRepository.findById(parseUuid(userId))
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
        if (request.getName() != null) {
            user.setName(request.getName());
        }
        if (request.getPhone() != null) {
            user.setPhone(request.getPhone());
        }
        return userMapper.toUserResponse(userRepository.save(user));
    }

    public void changePassword(String userId, ChangePasswordRequest request) {
        User user = userRepository.findById(parseUuid(userId))
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPassword())) {
            throw new AppException(ErrorCode.INVALID_PASSWORD);
        }
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }

    public void resetPassword(String email, String newPassword) {
        User user = userRepository.findByEmailAndDeletedFalse(email)
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
    }

    private UUID parseUuid(String id) {
        try {
            return UUID.fromString(id);
        } catch (IllegalArgumentException e) {
            throw new AppException(ErrorCode.ACCOUNT_NOT_FOUND);
        }
    }
}
