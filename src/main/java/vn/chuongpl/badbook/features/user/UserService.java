package vn.chuongpl.badbook.features.user;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
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
import vn.chuongpl.badbook.features.user.dto.request.UserCreateRequest;
import vn.chuongpl.badbook.features.user.dto.request.UserUpdateRequest;
import vn.chuongpl.badbook.features.user.dto.response.UserResponse;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = lombok.AccessLevel.PRIVATE, makeFinal = true)
public class UserService {
//    RoleRepository roleRepository;
    UserRepository userRepository;
    PasswordEncoder passwordEncoder;
    UserMapper userMapper;


    protected User getUserById(String id) {
        return userRepository.findById(parseUuid(id))
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
    }

    boolean existById(String id) {
        return userRepository.existsById(parseUuid(id));
    }

    public UserResponse createUser(UserCreateRequest request) {
        if(!verifyEmail(request.getEmail())){
            throw new AppException(ErrorCode.EMAIL_EXISTED);
        }
        User user = userMapper.toUser(request);
        user.setPassword(passwordEncoder.encode(request.getPassword()));
//        HashSet<Role> roles = new HashSet<>();
//        roleRepository.findById("USER").ifPresent(roles::add);
//        user.setRoles(roles);
        user.setCreatedAt(LocalDateTime.now());
        return userMapper.toUserResponse(userRepository.save(user));
    }



    public Boolean verifyEmail(String emailRequest) {
        Optional<User> user = userRepository.findByEmailAndDeletedFalse(emailRequest);
        return !user.isPresent();
    }

    public UserResponse updateUser(String email, UserUpdateRequest request) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
        userMapper.toUpdate(user, request);
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        return userMapper.toUserResponse(userRepository.save(user));
    }

    public PageResponse<UserResponse> getAllUser(Integer page) {
        int limit = 2 ;
        int pageCurrent = (page > 0 && page != null) ? page - 1 : 0;
        Pageable pageable = PageRequest.of(pageCurrent, limit , Sort.by(Sort.Direction.DESC , "name"));
        List<String> roles = List.of(Role.USER.name(),
                Role.VENUE_MANAGER.name(),
                Role.ADMIN.name());
        Page<User> users = userRepository.findByRolesIn(roles , pageable);

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

//    public UserResponse addAdminRole(String id) {
//        User user = userRepository.findById(id)
//                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
//
//        HashSet<Role> roles = new HashSet<>(user.getRoles());
//
//        Role adminRole = roleRepository.findById("ADMIN")
//                .orElseThrow(() -> new AppException(ErrorCode.ROLE_NOT_FOUND));
//
//        roles.add(adminRole);
//        user.setRoles(roles);
//        return userMapper.toUserResponse(userRepository.save(user));
//    }
//
//    public SummaryResponse getUserSummary() {
//
//        long totalUsers = userRepository.count();
//
//        LocalDateTime now = LocalDateTime.now();
//
//        LocalDateTime startTimeCurrent = now.withDayOfMonth(1).toLocalDate().atStartOfDay();
//        LocalDateTime endTimeCurrent = now.toLocalDate().atTime(LocalTime.MAX); // 23:59:59.999...
//
//        LocalDateTime previousPeriod = now.minusMonths(1);
//        LocalDateTime startTimePrevious = previousPeriod.withDayOfMonth(1).toLocalDate().atStartOfDay();
//        LocalDateTime endTimePrevious = previousPeriod.toLocalDate().atTime(LocalTime.MAX);
//
//        long currentPeriodCount = userRepository.countByCreatedAtBetweenAndDeletedFalse(startTimeCurrent, endTimeCurrent);
//        long previousPeriodCount = userRepository.countByCreatedAtBetweenAndDeletedFalse(startTimePrevious, endTimePrevious);
//
//        double changePercentage = 0.0;
//        String direction = "neutral";
//
//        if (previousPeriodCount > 0) {
//            changePercentage = ((double) (currentPeriodCount - previousPeriodCount) / previousPeriodCount) * 100.0;
//        } else if (previousPeriodCount == 0 && currentPeriodCount > 0) {
//            changePercentage = 100.0;
//        }
//
//        if (changePercentage > 0) {
//            direction = "increase";
//        } else if (changePercentage < 0) {
//            direction = "decrease";
//        }
//
//        double roundedPercentage = Math.round(changePercentage * 100.0) / 100.0;
//
//        return SummaryResponse.builder()
//                .total(totalUsers)
//                .changeAmount(currentPeriodCount - previousPeriodCount)
//                .changePercentage(roundedPercentage)
//                .direction(direction)
//                .build();
//    }

    public User getUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
    }

    public UserResponse getUserResponseById(String id) {
        if(id == null || id.isEmpty()) {
            throw new AppException(ErrorCode.ACCOUNT_NOT_FOUND);
        }
        User user = userRepository.findById(parseUuid(id))
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
        return userMapper.toUserResponse(user);
    }

    private UUID parseUuid(String id) {
        try {
            return UUID.fromString(id);
        } catch (IllegalArgumentException e) {
            throw new AppException(ErrorCode.ACCOUNT_NOT_FOUND);
        }
    }
}
