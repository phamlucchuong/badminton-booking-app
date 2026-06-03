# Badminton Booking BE — Migration Implementation Plan (Phase 1 & 2)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate BIGFOOD-BE infrastructure into badminton-booking-be, then build Venue + Court + Product management.

**Architecture:** Feature-based modules under `vn.chuongpl.badbook.features.*`, shared infra in `configuration/` and `common/`. Each phase produces a deployable, testable slice.

**Tech Stack:** Spring Boot 3.5.11, PostgreSQL, Redis, Flyway, MapStruct, Cloudinary, JavaMail OTP, Goong API (WebFlux WebClient), VNPay.

---

## PHASE 1 — Foundation

### Task 1: Add missing dependencies to pom.xml

**Files:**
- Modify: `pom.xml`

- [ ] **Step 1: Add spring-boot-starter-webflux (for Goong WebClient) and H2 test dependency**

In `pom.xml`, inside `<dependencies>`, add:
```xml
<!-- WebFlux for Goong API WebClient -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-webflux</artifactId>
</dependency>

<!-- H2 for unit tests -->
<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <scope>test</scope>
</dependency>
```

- [ ] **Step 2: Create test application config**

Create `src/test/resources/application-test.yaml`:
```yaml
spring:
  datasource:
    url: jdbc:h2:mem:testdb;MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH
    driver-class-name: org.h2.Driver
    username: sa
    password:
  jpa:
    hibernate:
      ddl-auto: create-drop
    database-platform: org.hibernate.dialect.H2Dialect
    show-sql: false
  flyway:
    enabled: false
  data:
    redis:
      host: localhost
      port: 6379

JWT_SECRET: "test-secret-key-for-unit-tests-must-be-at-least-32-chars"
fe_domain: "http://localhost:3000"

cloudinary:
  cloudName: test
  apiKey: test
  apiSecret: test

goong:
  api:
    key: test-key
    base-url: https://rsapi.goong.io

spring.mail.username: test@test.com
```

- [ ] **Step 3: Build project to confirm dependencies resolve**

```bash
cd /home/chuongpl/projects/bad/badminton-booking-be && mvn dependency:resolve -q
```
Expected: BUILD SUCCESS

- [ ] **Step 4: Commit**
```bash
git add pom.xml src/test/resources/application-test.yaml
git commit -m "chore: add webflux, H2 test deps and test config"
```

---

### Task 2: Fix Role enum and clean ErrorCode

**Files:**
- Modify: `src/main/java/vn/chuongpl/badbook/common/enums/Role.java`
- Modify: `src/main/java/vn/chuongpl/badbook/common/enums/ErrorCode.java`
- Modify: `src/main/java/vn/chuongpl/badbook/features/user/UserService.java`

- [ ] **Step 1: Update Role enum** — replace `RESTAURANT` with `VENUE_MANAGER`

Full content of `src/main/java/vn/chuongpl/badbook/common/enums/Role.java`:
```java
package vn.chuongpl.badbook.common.enums;

public enum Role {
    ADMIN,
    VENUE_MANAGER,
    USER
}
```

- [ ] **Step 2: Replace ErrorCode enum with clean domain-specific codes**

Full content of `src/main/java/vn/chuongpl/badbook/common/enums/ErrorCode.java`:
```java
package vn.chuongpl.badbook.common.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum ErrorCode {
    // System
    UNCATEGORIZED_EXCEPTION(9999, "Lỗi hệ thống không xác định"),
    UNAUTHENTICATED(1001, "Bạn chưa đăng nhập"),
    UNAUTHORIZED(1002, "Bạn không có quyền thực hiện thao tác này"),
    ID_INVALID(1003, "ID không hợp lệ"),
    FILE_UPLOAD_FAILED(1004, "Upload file thất bại"),
    GEOCODING_FAILED(1005, "Không thể chuyển đổi địa chỉ thành tọa độ"),

    // Auth / User
    ACCOUNT_NOT_FOUND(2001, "Tài khoản không tồn tại"),
    AUTHENTICATION_FAILED(2002, "Mật khẩu không đúng"),
    EMAIL_EXISTED(2003, "Email đã tồn tại"),
    OTP_INVALID(2004, "Mã OTP không hợp lệ hoặc đã hết hạn"),

    // Role / Permission
    ROLE_NOT_FOUND(3001, "Role không tồn tại"),
    ROLE_ALREADY_EXISTS(3002, "Role đã tồn tại"),
    PERMISSION_EXISTED(3003, "Permission đã tồn tại"),

    // Venue
    VENUE_NOT_FOUND(4001, "Cơ sở không tồn tại"),
    VENUE_NOT_APPROVED(4002, "Cơ sở chưa được duyệt"),
    VENUE_ALREADY_EXISTS(4003, "Người dùng đã đăng ký một cơ sở"),
    VENUE_NOT_OWNED_BY_USER(4004, "Bạn không phải chủ cơ sở này"),

    // Court
    COURT_NOT_FOUND(5001, "Sân không tồn tại"),
    COURT_NOT_AVAILABLE(5002, "Sân không khả dụng trong khung giờ này"),
    COURT_NOT_IN_VENUE(5003, "Sân không thuộc cơ sở này"),

    // Product
    PRODUCT_NOT_FOUND(6001, "Sản phẩm không tồn tại"),
    PRODUCT_OUT_OF_STOCK(6002, "Sản phẩm đã hết hàng"),
    PRODUCT_NOT_IN_VENUE(6003, "Sản phẩm không thuộc cơ sở này"),

    // Booking
    BOOKING_NOT_FOUND(7001, "Lịch đặt không tồn tại"),
    BOOKING_CONFLICT(7002, "Sân đã được đặt trong khung giờ này"),
    BOOKING_CANNOT_CANCEL(7003, "Không thể hủy lịch đặt ở trạng thái hiện tại"),
    BOOKING_NOT_COMPLETED(7004, "Lịch đặt chưa hoàn thành"),

    // Payment
    PAYMENT_NOT_FOUND(8001, "Thông tin thanh toán không tồn tại"),
    PAYMENT_FAILED(8002, "Thanh toán thất bại"),
    PAYMENT_ALREADY_PROCESSED(8003, "Thanh toán đã được xử lý"),

    // Review
    REVIEW_ONLY_AFTER_COMPLETION(9001, "Chỉ được đánh giá sau khi hoàn thành lịch đặt"),
    REVIEW_ALREADY_SUBMITTED(9002, "Bạn đã đánh giá booking này"),
    REVIEW_NOT_FOUND(9003, "Đánh giá không tồn tại"),
    REVIEW_ALREADY_REPLIED(9004, "Đánh giá đã được phản hồi"),

    // Finance
    INVOICE_NOT_FOUND(10001, "Hóa đơn không tồn tại"),
    PLATFORM_FEE_ALREADY_PAID(10002, "Phí sàn đã được thanh toán"),

    // Schedule
    SCHEDULE_NOT_FOUND(11001, "Lịch cố định không tồn tại"),
    SCHEDULE_CONFLICT(11002, "Lịch cố định bị trùng với lịch đặt hiện có");

    private final int code;
    private final String message;
}
```

- [ ] **Step 3: Fix UserService.getAllUser — remove reference to Role.RESTAURANT**

In `src/main/java/vn/chuongpl/badbook/features/user/UserService.java`, replace:
```java
List<String> roles = List.of(Role.USER.name(), Role.ADMIN.name());
```
with:
```java
List<String> roles = List.of(Role.USER.name(), Role.VENUE_MANAGER.name(), Role.ADMIN.name());
```

- [ ] **Step 4: Verify project builds**
```bash
mvn compile -q
```
Expected: BUILD SUCCESS

- [ ] **Step 5: Commit**
```bash
git add src/main/java/vn/chuongpl/badbook/common/enums/
git add src/main/java/vn/chuongpl/badbook/features/user/UserService.java
git commit -m "refactor: replace RESTAURANT role with VENUE_MANAGER, clean ErrorCode enum"
```

---

### Task 3: Update ApplicationInitConfig to seed all 3 roles

**Files:**
- Modify: `src/main/java/vn/chuongpl/badbook/configuration/ApplicationInitConfig.java`

- [ ] **Step 1: Write failing test**

Create `src/test/java/vn/chuongpl/badbook/configuration/ApplicationInitConfigTest.java`:
```java
package vn.chuongpl.badbook.configuration;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.boot.ApplicationArguments;
import org.springframework.security.crypto.password.PasswordEncoder;
import vn.chuongpl.badbook.features.role.Role;
import vn.chuongpl.badbook.features.role.RoleRepository;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;

import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ApplicationInitConfigTest {

    @Mock UserRepository userRepository;
    @Mock RoleRepository roleRepository;
    @Mock PasswordEncoder passwordEncoder;

    @Test
    void shouldSeedThreeRolesAndAdminUser() throws Exception {
        when(userRepository.findByEmail("admin@gmail.com")).thenReturn(Optional.empty());
        when(roleRepository.findById("ADMIN")).thenReturn(Optional.of(Role.builder().name("ADMIN").build()));
        when(roleRepository.findById("VENUE_MANAGER")).thenReturn(Optional.of(Role.builder().name("VENUE_MANAGER").build()));
        when(roleRepository.findById("USER")).thenReturn(Optional.of(Role.builder().name("USER").build()));
        when(passwordEncoder.encode(any())).thenReturn("hashed");
        when(userRepository.save(any())).thenAnswer(i -> i.getArgument(0));

        ApplicationInitConfig config = new ApplicationInitConfig(passwordEncoder);
        config.applicationRunner(userRepository, roleRepository)
              .run(mock(ApplicationArguments.class));

        verify(roleRepository, atLeastOnce()).findById("ADMIN");
        verify(roleRepository, atLeastOnce()).findById("VENUE_MANAGER");
        verify(roleRepository, atLeastOnce()).findById("USER");
        verify(userRepository).save(argThat(u -> ((User) u).getEmail().equals("admin@gmail.com")));
    }
}
```

- [ ] **Step 2: Run test — expect FAIL (missing VENUE_MANAGER/USER seeding)**
```bash
mvn test -Dtest=ApplicationInitConfigTest -q 2>&1 | tail -10
```

- [ ] **Step 3: Update ApplicationInitConfig**

Full content of `src/main/java/vn/chuongpl/badbook/configuration/ApplicationInitConfig.java`:
```java
package vn.chuongpl.badbook.configuration;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.experimental.NonFinal;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;
import vn.chuongpl.badbook.features.role.Role;
import vn.chuongpl.badbook.features.role.RoleRepository;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.List;

@Configuration
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class ApplicationInitConfig {

    @NonFinal static final String ADMIN_EMAIL = "admin@gmail.com";
    @NonFinal static final String ADMIN_PASSWORD = "Admin@123456";

    PasswordEncoder passwordEncoder;

    @Bean
    @Transactional
    ApplicationRunner applicationRunner(UserRepository userRepository, RoleRepository roleRepository) {
        return args -> {
            seedRole(roleRepository, "ADMIN", "Quản trị viên hệ thống");
            seedRole(roleRepository, "VENUE_MANAGER", "Chủ sân cầu lông");
            seedRole(roleRepository, "USER", "Người dùng");

            if (userRepository.findByEmail(ADMIN_EMAIL).isEmpty()) {
                Role adminRole = roleRepository.findById("ADMIN").orElseThrow();
                var roles = new HashSet<Role>();
                roles.add(adminRole);
                userRepository.save(User.builder()
                        .name("Admin")
                        .email(ADMIN_EMAIL)
                        .password(passwordEncoder.encode(ADMIN_PASSWORD))
                        .phone("0000000000")
                        .roles(roles)
                        .createdAt(LocalDateTime.now())
                        .build());
                log.info("Admin account created: {}", ADMIN_EMAIL);
            }
        };
    }

    private void seedRole(RoleRepository repo, String name, String description) {
        if (repo.findById(name).isEmpty()) {
            repo.save(Role.builder().name(name).description(description).build());
        }
    }
}
```

- [ ] **Step 4: Run test — expect PASS**
```bash
mvn test -Dtest=ApplicationInitConfigTest -q 2>&1 | tail -5
```

- [ ] **Step 5: Commit**
```bash
git add src/main/java/vn/chuongpl/badbook/configuration/ApplicationInitConfig.java
git add src/test/java/vn/chuongpl/badbook/configuration/ApplicationInitConfigTest.java
git commit -m "feat: seed ADMIN/VENUE_MANAGER/USER roles on startup"
```

---

### Task 4: Add Cloudinary media feature

**Files:**
- Create: `src/main/java/vn/chuongpl/badbook/configuration/CloudinaryConfig.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/media/CloudinaryService.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/media/MediaController.java`
- Modify: `src/main/resources/application.yaml`

- [ ] **Step 1: Add Cloudinary config to application.yaml**

Add at the end of `src/main/resources/application.yaml`:
```yaml
cloudinary:
  cloudName: ${CLOUDINARY_CLOUD_NAME:your-cloud-name}
  apiKey: ${CLOUDINARY_API_KEY:your-api-key}
  apiSecret: ${CLOUDINARY_API_SECRET:your-api-secret}
```

- [ ] **Step 2: Write failing test**

Create `src/test/java/vn/chuongpl/badbook/features/media/CloudinaryServiceTest.java`:
```java
package vn.chuongpl.badbook.features.media;

import com.cloudinary.Cloudinary;
import com.cloudinary.Uploader;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mock.web.MockMultipartFile;

import java.io.IOException;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class CloudinaryServiceTest {

    @Mock Cloudinary cloudinary;
    @InjectMocks CloudinaryService cloudinaryService;

    @Test
    void uploadFile_returnsPublicId() throws IOException {
        Uploader uploader = mock(Uploader.class);
        when(cloudinary.uploader()).thenReturn(uploader);
        when(uploader.upload(any(byte[].class), any(Map.class)))
                .thenReturn(Map.of("public_id", "badbook/venues/abc123"));

        MockMultipartFile file = new MockMultipartFile("file", "test.jpg", "image/jpeg", "data".getBytes());
        String result = cloudinaryService.uploadFile(file, "venues");

        assertThat(result).isEqualTo("badbook/venues/abc123");
    }
}
```

- [ ] **Step 3: Run test — expect FAIL (class not found)**
```bash
mvn test -Dtest=CloudinaryServiceTest -q 2>&1 | tail -5
```

- [ ] **Step 4: Create CloudinaryConfig**

Create `src/main/java/vn/chuongpl/badbook/configuration/CloudinaryConfig.java`:
```java
package vn.chuongpl.badbook.configuration;

import com.cloudinary.Cloudinary;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Map;

@Configuration
public class CloudinaryConfig {

    @Value("${cloudinary.cloudName}") String cloudName;
    @Value("${cloudinary.apiKey}") String apiKey;
    @Value("${cloudinary.apiSecret}") String apiSecret;

    @Bean
    public Cloudinary cloudinary() {
        return new Cloudinary(Map.of(
                "cloud_name", cloudName,
                "api_key", apiKey,
                "api_secret", apiSecret
        ));
    }
}
```

- [ ] **Step 5: Create CloudinaryService**

Create `src/main/java/vn/chuongpl/badbook/features/media/CloudinaryService.java`:
```java
package vn.chuongpl.badbook.features.media;

import com.cloudinary.Cloudinary;
import lombok.RequiredArgsConstructor;
import org.mapstruct.Named;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class CloudinaryService {

    private final Cloudinary cloudinary;

    public String uploadFile(MultipartFile file, String folder) throws IOException {
        Map<String, Object> result = cloudinary.uploader().upload(
                file.getBytes(),
                Map.of("resource_type", "auto", "folder", "badbook/" + folder)
        );
        return (String) result.get("public_id");
    }

    public void deleteFile(String publicId) throws IOException {
        cloudinary.uploader().destroy(publicId, Map.of("resource_type", "image"));
    }

    @Named("generateUrl")
    public String generateUrl(String publicId) {
        if (publicId == null) return null;
        return cloudinary.url().secure(true).generate(publicId);
    }
}
```

- [ ] **Step 6: Create MediaController**

Create `src/main/java/vn/chuongpl/badbook/features/media/MediaController.java`:
```java
package vn.chuongpl.badbook.features.media;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.exception.AppException;

import java.io.IOException;

@RestController
@RequestMapping("/api/media")
@RequiredArgsConstructor
public class MediaController {

    private final CloudinaryService cloudinaryService;

    @PostMapping
    public ApiResponse<String> upload(
            @RequestParam("folder") String folder,
            @RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) throw new AppException(ErrorCode.FILE_UPLOAD_FAILED);
        try {
            return ApiResponse.<String>builder()
                    .data(cloudinaryService.uploadFile(file, folder))
                    .build();
        } catch (IOException e) {
            throw new AppException(ErrorCode.FILE_UPLOAD_FAILED);
        }
    }
}
```

- [ ] **Step 7: Run test — expect PASS**
```bash
mvn test -Dtest=CloudinaryServiceTest -q 2>&1 | tail -5
```

- [ ] **Step 8: Commit**
```bash
git add src/main/java/vn/chuongpl/badbook/configuration/CloudinaryConfig.java
git add src/main/java/vn/chuongpl/badbook/features/media/
git add src/main/resources/application.yaml
git add src/test/java/vn/chuongpl/badbook/features/media/
git commit -m "feat: add Cloudinary media upload feature"
```

---

### Task 5: Add email OTP feature

**Files:**
- Create: `src/main/java/vn/chuongpl/badbook/features/otp/OtpService.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/otp/OtpController.java`
- Modify: `src/main/resources/application.yaml`

- [ ] **Step 1: Add mail config to application.yaml**

Add to `src/main/resources/application.yaml`:
```yaml
spring:
  mail:
    host: ${MAIL_HOST:smtp.gmail.com}
    port: ${MAIL_PORT:587}
    username: ${MAIL_USERNAME:your-email@gmail.com}
    password: ${MAIL_PASSWORD:your-app-password}
    properties:
      mail.smtp.auth: true
      mail.smtp.starttls.enable: true
```

- [ ] **Step 2: Write failing test**

Create `src/test/java/vn/chuongpl/badbook/features/otp/OtpServiceTest.java`:
```java
package vn.chuongpl.badbook.features.otp;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.test.util.ReflectionTestUtils;

import static org.assertj.core.api.Assertions.assertThat;

@ExtendWith(MockitoExtension.class)
class OtpServiceTest {

    @Mock JavaMailSender mailSender;
    @InjectMocks OtpService otpService;

    @Test
    void generateOtp_produces4DigitCode() {
        ReflectionTestUtils.setField(otpService, "fromEmail", "noreply@test.com");
        String otp = otpService.generateOtp("test@email.com");
        assertThat(otp).matches("\\d{4}");
    }

    @Test
    void validateOtp_returnsTrueForCorrectOtp() {
        ReflectionTestUtils.setField(otpService, "fromEmail", "noreply@test.com");
        String otp = otpService.generateOtp("user@test.com");
        assertThat(otpService.validateOtp("user@test.com", otp)).isTrue();
    }

    @Test
    void validateOtp_returnsFalseForWrongOtp() {
        ReflectionTestUtils.setField(otpService, "fromEmail", "noreply@test.com");
        otpService.generateOtp("user@test.com");
        assertThat(otpService.validateOtp("user@test.com", "0000")).isFalse();
    }

    @Test
    void validateOtp_returnsFalseAfterSuccessfulVerification() {
        ReflectionTestUtils.setField(otpService, "fromEmail", "noreply@test.com");
        String otp = otpService.generateOtp("user@test.com");
        otpService.validateOtp("user@test.com", otp);
        assertThat(otpService.validateOtp("user@test.com", otp)).isFalse();
    }
}
```

- [ ] **Step 3: Run test — expect FAIL**
```bash
mvn test -Dtest=OtpServiceTest -q 2>&1 | tail -5
```

- [ ] **Step 4: Create OtpService**

Create `src/main/java/vn/chuongpl/badbook/features/otp/OtpService.java`:
```java
package vn.chuongpl.badbook.features.otp;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
@RequiredArgsConstructor
public class OtpService {

    private final JavaMailSender mailSender;
    private final Map<String, OtpEntry> store = new ConcurrentHashMap<>();
    private final SecureRandom random = new SecureRandom();

    @Value("${spring.mail.username}")
    private String fromEmail;

    public String generateOtp(String key) {
        String otp = String.format("%04d", random.nextInt(10000));
        store.put(key, new OtpEntry(otp, Instant.now().plusSeconds(120)));
        return otp;
    }

    public boolean validateOtp(String key, String otp) {
        OtpEntry entry = store.get(key);
        if (entry == null) return false;
        if (Instant.now().isAfter(entry.expiresAt())) { store.remove(key); return false; }
        if (!entry.otp().equals(otp)) return false;
        store.remove(key);
        return true;
    }

    public void sendOtp(String email, String otp) {
        SimpleMailMessage msg = new SimpleMailMessage();
        msg.setFrom(fromEmail);
        msg.setTo(email);
        msg.setSubject("[BadBook] Mã xác thực OTP");
        msg.setText("Mã OTP của bạn là: " + otp + "\nMã có hiệu lực trong 2 phút.");
        mailSender.send(msg);
    }

    private record OtpEntry(String otp, Instant expiresAt) {}
}
```

- [ ] **Step 5: Create OtpController**

Create `src/main/java/vn/chuongpl/badbook/features/otp/OtpController.java`:
```java
package vn.chuongpl.badbook.features.otp;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.exception.AppException;

@RestController
@RequestMapping("/api/otp")
@RequiredArgsConstructor
public class OtpController {

    private final OtpService otpService;

    @PostMapping("/send")
    public ApiResponse<Void> sendOtp(@RequestParam String email) {
        String otp = otpService.generateOtp(email);
        otpService.sendOtp(email, otp);
        return ApiResponse.<Void>builder().message("OTP đã được gửi đến email của bạn").build();
    }

    @GetMapping("/verify")
    public ApiResponse<Boolean> verifyOtp(@RequestParam String email, @RequestParam String otp) {
        boolean valid = otpService.validateOtp(email, otp);
        if (!valid) throw new AppException(ErrorCode.OTP_INVALID);
        return ApiResponse.<Boolean>builder().data(true).build();
    }
}
```

- [ ] **Step 6: Run tests — expect PASS**
```bash
mvn test -Dtest=OtpServiceTest -q 2>&1 | tail -5
```

- [ ] **Step 7: Commit**
```bash
git add src/main/java/vn/chuongpl/badbook/features/otp/
git add src/main/resources/application.yaml
git add src/test/java/vn/chuongpl/badbook/features/otp/
git commit -m "feat: add email OTP send/verify feature"
```

---

### Task 6: Add Goong location feature

**Files:**
- Create: `src/main/java/vn/chuongpl/badbook/configuration/GoongWebClientConfig.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/location/dto/GoongLocation.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/location/dto/GeocodingResponse.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/location/LocationService.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/location/LocationController.java`
- Modify: `src/main/resources/application.yaml`

- [ ] **Step 1: Add Goong config to application.yaml**

Add to `src/main/resources/application.yaml`:
```yaml
goong:
  api:
    key: ${GOONG_API_KEY:your-goong-key}
    base-url: https://rsapi.goong.io
```

- [ ] **Step 2: Create GoongWebClientConfig**

Create `src/main/java/vn/chuongpl/badbook/configuration/GoongWebClientConfig.java`:
```java
package vn.chuongpl.badbook.configuration;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;

@Configuration
public class GoongWebClientConfig {

    @Bean
    public WebClient goongWebClient() {
        return WebClient.builder()
                .baseUrl("https://rsapi.goong.io")
                .defaultHeader("Content-Type", "application/json")
                .build();
    }
}
```

- [ ] **Step 3: Create Goong response DTOs**

Create `src/main/java/vn/chuongpl/badbook/features/location/dto/GoongLocation.java`:
```java
package vn.chuongpl.badbook.features.location.dto;

import lombok.Data;

@Data
public class GoongLocation {
    private double lat;
    private double lng;
}
```

Create `src/main/java/vn/chuongpl/badbook/features/location/dto/GeocodingResponse.java`:
```java
package vn.chuongpl.badbook.features.location.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.List;

@Data
public class GeocodingResponse {
    private String status;
    private List<Result> results;

    @Data
    public static class Result {
        @JsonProperty("formatted_address")
        private String formattedAddress;
        private Geometry geometry;
    }

    @Data
    public static class Geometry {
        private GoongLocation location;
    }
}
```

- [ ] **Step 4: Create LocationService**

Create `src/main/java/vn/chuongpl/badbook/features/location/LocationService.java`:
```java
package vn.chuongpl.badbook.features.location;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.util.UriComponentsBuilder;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.location.dto.GeocodingResponse;
import vn.chuongpl.badbook.features.location.dto.GoongLocation;

@Service
@RequiredArgsConstructor
public class LocationService {

    private final WebClient goongWebClient;

    @Value("${goong.api.key}") String goongApiKey;
    @Value("${goong.api.base-url}") String goongBaseUrl;

    public GoongLocation geocode(String address) {
        String url = UriComponentsBuilder.fromHttpUrl(goongBaseUrl)
                .path("/geocode")
                .queryParam("address", address)
                .queryParam("api_key", goongApiKey)
                .build().toUriString();

        GeocodingResponse response = goongWebClient.get()
                .uri(url).retrieve()
                .bodyToMono(GeocodingResponse.class).block();

        if (response != null && "OK".equals(response.getStatus()) && !response.getResults().isEmpty()) {
            return response.getResults().get(0).getGeometry().getLocation();
        }
        throw new AppException(ErrorCode.GEOCODING_FAILED);
    }

    public String reverseGeocode(double lat, double lng) {
        String url = UriComponentsBuilder.fromHttpUrl(goongBaseUrl)
                .path("/geocode")
                .queryParam("latlng", lat + "," + lng)
                .queryParam("api_key", goongApiKey)
                .build().toUriString();

        GeocodingResponse response = goongWebClient.get()
                .uri(url).retrieve()
                .bodyToMono(GeocodingResponse.class).block();

        if (response != null && "OK".equals(response.getStatus()) && !response.getResults().isEmpty()) {
            return response.getResults().get(0).getFormattedAddress();
        }
        throw new AppException(ErrorCode.GEOCODING_FAILED);
    }
}
```

- [ ] **Step 5: Create LocationController**

Create `src/main/java/vn/chuongpl/badbook/features/location/LocationController.java`:
```java
package vn.chuongpl.badbook.features.location;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.features.location.dto.GoongLocation;

@RestController
@RequestMapping("/api/location")
@RequiredArgsConstructor
public class LocationController {

    private final LocationService locationService;

    @PostMapping("/geocode")
    public ApiResponse<GoongLocation> geocode(@RequestBody String address) {
        return ApiResponse.<GoongLocation>builder()
                .data(locationService.geocode(address)).build();
    }

    @GetMapping("/reverse-geocode")
    public ApiResponse<String> reverseGeocode(@RequestParam double lat, @RequestParam double lng) {
        return ApiResponse.<String>builder()
                .data(locationService.reverseGeocode(lat, lng)).build();
    }
}
```

- [ ] **Step 6: Build to verify**
```bash
mvn compile -q && echo "OK"
```

- [ ] **Step 7: Commit**
```bash
git add src/main/java/vn/chuongpl/badbook/configuration/GoongWebClientConfig.java
git add src/main/java/vn/chuongpl/badbook/features/location/
git add src/main/resources/application.yaml
git commit -m "feat: add Goong geocoding location feature"
```

---

### Task 7: Fix ApiResponse, update SecurityConfig public endpoints

**Files:**
- Modify: `src/main/java/vn/chuongpl/badbook/common/ApiResponse.java`
- Modify: `src/main/java/vn/chuongpl/badbook/configuration/SecurityConfig.java`
- Add register to: `src/main/java/vn/chuongpl/badbook/features/auth/AuthController.java`
- Add register to: `src/main/java/vn/chuongpl/badbook/features/user/UserService.java`
- Add RegisterRequest: `src/main/java/vn/chuongpl/badbook/features/auth/dto/request/RegisterRequest.java`

- [ ] **Step 1: Fix ApiResponse to use `data` field consistently**

Check `src/main/java/vn/chuongpl/badbook/common/ApiResponse.java`. If it uses `results` instead of `data`, update it. Full content:
```java
package vn.chuongpl.badbook.common;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.*;
import lombok.experimental.FieldDefaults;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ApiResponse<T> {
    @Builder.Default int code = 200;
    String message;
    T data;
}
```

- [ ] **Step 2: Create RegisterRequest**

Create `src/main/java/vn/chuongpl/badbook/features/auth/dto/request/RegisterRequest.java`:
```java
package vn.chuongpl.badbook.features.auth.dto.request;

import lombok.*;
import lombok.experimental.FieldDefaults;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class RegisterRequest {
    String name;
    String email;
    String password;
    String phone;
}
```

- [ ] **Step 3: Add register method to UserService**

In `src/main/java/vn/chuongpl/badbook/features/user/UserService.java`, add import and method:
```java
// Add import:
import vn.chuongpl.badbook.features.auth.dto.request.RegisterRequest;
import vn.chuongpl.badbook.features.role.RoleRepository;

// Add field:
RoleRepository roleRepository;

// Add method:
public UserResponse register(RegisterRequest request) {
    if (userRepository.findByEmail(request.getEmail()).isPresent()) {
        throw new AppException(ErrorCode.EMAIL_EXISTED);
    }
    var userRole = roleRepository.findById("USER").orElseThrow(() -> new AppException(ErrorCode.ROLE_NOT_FOUND));
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
```

Also add missing imports at top of UserService:
```java
import java.util.HashSet;
import java.util.Set;
import vn.chuongpl.badbook.features.role.RoleRepository;
import vn.chuongpl.badbook.features.auth.dto.request.RegisterRequest;
```

- [ ] **Step 4: Add /register endpoint to AuthController**

In `src/main/java/vn/chuongpl/badbook/features/auth/AuthController.java`, add:
```java
// Add import:
import vn.chuongpl.badbook.features.auth.dto.request.RegisterRequest;
import vn.chuongpl.badbook.features.user.UserService;
import vn.chuongpl.badbook.features.user.dto.response.UserResponse;

// Add field (via @Autowired or constructor):
@Autowired UserService userService;

// Add endpoint:
@PostMapping("/register")
public ApiResponse<UserResponse> register(@RequestBody RegisterRequest request) {
    return ApiResponse.<UserResponse>builder()
            .data(userService.register(request))
            .message("Đăng ký thành công")
            .build();
}
```

- [ ] **Step 5: Update SecurityConfig with correct public endpoints**

Replace `PUBLIC_POST_ENDPOINT` array content in `src/main/java/vn/chuongpl/badbook/configuration/SecurityConfig.java`:
```java
private final String[] PUBLIC_POST_ENDPOINT = {
    "api/auth",
    "api/auth/register",
    "api/otp/send",
    "api/location/geocode",
    "api/media"
};

private final String[] PUBLIC_GET_ENDPOINT = {
    "api/users/verify-email/{email}",
    "api/otp/verify",
    "api/location/reverse-geocode",
    "/v3/api-docs/**",
    "/swagger-ui/**",
    "/swagger-ui.html"
};
```

Also remove `SWAGGER_ENDPOINT` array and inline them, and remove `.requestMatchers(SWAGGER_ENDPOINT).permitAll()` line if separate. Update the `filterChain` method:
```java
@Bean
public SecurityFilterChain filterChain(HttpSecurity httpSecurity) throws Exception {
    httpSecurity
            .csrf(csrf -> csrf.disable())
            .cors(Customizer.withDefaults())
            .addFilterBefore(jwtBlacklistFilter, BearerTokenAuthenticationFilter.class)
            .authorizeHttpRequests(request -> request
                    .requestMatchers(HttpMethod.POST, PUBLIC_POST_ENDPOINT).permitAll()
                    .requestMatchers(HttpMethod.GET, PUBLIC_GET_ENDPOINT).permitAll()
                    .anyRequest().authenticated())
            .oauth2ResourceServer(oauth2 -> oauth2.jwt(jwt -> jwt
                    .decoder(customerJwtDecoder)
                    .jwtAuthenticationConverter(jwtAuthenticationConverter())));
    return httpSecurity.build();
}
```

- [ ] **Step 6: Build and verify**
```bash
mvn compile -q && echo "COMPILE OK"
```

- [ ] **Step 7: Commit**
```bash
git add src/main/java/vn/chuongpl/badbook/
git commit -m "feat: add register endpoint, fix SecurityConfig public endpoints"
```

---

### Task 8: Phase 1 smoke test — run the application

- [ ] **Step 1: Start PostgreSQL and Redis** (assumes Docker Compose)
```bash
cd /home/chuongpl/projects/bad/badminton-booking-be && docker compose -f docker-compose.dev.yaml up -d
```

- [ ] **Step 2: Run Flyway migrations**
```bash
make migrate
```
Or: `mvn flyway:migrate -Dflyway.url=jdbc:postgresql://localhost:5432/badbook -Dflyway.user=admin -Dflyway.password=admin`

- [ ] **Step 3: Start application**
```bash
mvn spring-boot:run &
sleep 15
```

- [ ] **Step 4: Test auth endpoint**
```bash
curl -s -X POST http://localhost:8080/badbook/api/auth \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@gmail.com","password":"Admin@123456"}' | python3 -m json.tool
```
Expected: `{"code":200,"data":{"token":"eyJ...","authenticated":true}}`

- [ ] **Step 5: Test register endpoint**
```bash
curl -s -X POST http://localhost:8080/badbook/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@test.com","password":"Test@123","phone":"0909090909"}' | python3 -m json.tool
```
Expected: `{"code":200,"message":"Đăng ký thành công","data":{...}}`

- [ ] **Step 6: Stop application**
```bash
pkill -f "spring-boot:run"
```

- [ ] **Step 7: Commit Phase 1 completion tag**
```bash
git tag phase-1-complete
git commit --allow-empty -m "chore: Phase 1 Foundation complete — auth, media, OTP, location"
```

---

## PHASE 2 — Venue & Court Management

### Task 9: Add domain enums for Phase 2

**Files:**
- Create: `src/main/java/vn/chuongpl/badbook/common/enums/VenueStatus.java`
- Create: `src/main/java/vn/chuongpl/badbook/common/enums/CourtType.java`
- Create: `src/main/java/vn/chuongpl/badbook/common/enums/CourtStatus.java`
- Create: `src/main/java/vn/chuongpl/badbook/common/enums/ProductCategory.java`

- [ ] **Step 1: Create all enums**

`src/main/java/vn/chuongpl/badbook/common/enums/VenueStatus.java`:
```java
package vn.chuongpl.badbook.common.enums;

public enum VenueStatus {
    PENDING, ACTIVE, SUSPENDED, REJECTED
}
```

`src/main/java/vn/chuongpl/badbook/common/enums/CourtType.java`:
```java
package vn.chuongpl.badbook.common.enums;

public enum CourtType {
    STANDARD, PREMIUM, VIP
}
```

`src/main/java/vn/chuongpl/badbook/common/enums/CourtStatus.java`:
```java
package vn.chuongpl.badbook.common.enums;

public enum CourtStatus {
    ACTIVE, MAINTENANCE, INACTIVE
}
```

`src/main/java/vn/chuongpl/badbook/common/enums/ProductCategory.java`:
```java
package vn.chuongpl.badbook.common.enums;

public enum ProductCategory {
    RACKET_RENTAL, SHUTTLECOCK, BEVERAGE, EQUIPMENT, OTHER
}
```

- [ ] **Step 2: Commit**
```bash
git add src/main/java/vn/chuongpl/badbook/common/enums/
git commit -m "feat: add Phase 2 enums (VenueStatus, CourtType, CourtStatus, ProductCategory)"
```

---

### Task 10: Venue entity + Flyway V4

**Files:**
- Create: `src/main/resources/db/migration/V4__create_venues_table.sql`
- Create: `src/main/java/vn/chuongpl/badbook/features/venue/Venue.java`

- [ ] **Step 1: Create V4 migration**

Create `src/main/resources/db/migration/V4__create_venues_table.sql`:
```sql
CREATE TABLE venues (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id    UUID NOT NULL REFERENCES users(id),
    name        VARCHAR(255) NOT NULL,
    address     VARCHAR(500) NOT NULL,
    latitude    DECIMAL(10,8) NOT NULL,
    longitude   DECIMAL(11,8) NOT NULL,
    description TEXT,
    banner_ids  TEXT,
    license_id  VARCHAR(255) NOT NULL,
    status      VARCHAR(20) NOT NULL DEFAULT 'PENDING'
                    CHECK (status IN ('PENDING','ACTIVE','SUSPENDED','REJECTED')),
    open_time   TIME NOT NULL,
    close_time  TIME NOT NULL,
    platform_fee_rate DECIMAL(5,4) NOT NULL DEFAULT 0.1000,
    bank_name   VARCHAR(100),
    bank_number VARCHAR(50),
    bank_account_name VARCHAR(100),
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_venues_owner ON venues(owner_id);
CREATE INDEX idx_venues_status ON venues(status);
```

- [ ] **Step 2: Create Venue entity**

Create `src/main/java/vn/chuongpl/badbook/features/venue/Venue.java`:
```java
package vn.chuongpl.badbook.features.venue;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.VenueStatus;
import vn.chuongpl.badbook.features.user.User;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.UUID;

@Entity
@Table(name = "venues")
@Getter @Setter @Builder
@NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class Venue {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid")
    UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false)
    User owner;

    @Column(nullable = false)
    String name;

    @Column(nullable = false, length = 500)
    String address;

    @Column(nullable = false, precision = 10, scale = 8)
    BigDecimal latitude;

    @Column(nullable = false, precision = 11, scale = 8)
    BigDecimal longitude;

    @Column(columnDefinition = "TEXT")
    String description;

    @Column(name = "banner_ids")
    String bannerIds;

    @Column(name = "license_id", nullable = false)
    String licenseId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    VenueStatus status = VenueStatus.PENDING;

    @Column(name = "open_time", nullable = false)
    LocalTime openTime;

    @Column(name = "close_time", nullable = false)
    LocalTime closeTime;

    @Column(name = "platform_fee_rate", nullable = false, precision = 5, scale = 4)
    @Builder.Default
    BigDecimal platformFeeRate = new BigDecimal("0.1000");

    @Column(name = "bank_name")
    String bankName;

    @Column(name = "bank_number")
    String bankNumber;

    @Column(name = "bank_account_name")
    String bankAccountName;

    @Column(name = "created_at", updatable = false)
    LocalDateTime createdAt;

    @PrePersist
    void prePersist() { this.createdAt = LocalDateTime.now(); }
}
```

- [ ] **Step 3: Commit**
```bash
git add src/main/resources/db/migration/V4__create_venues_table.sql
git add src/main/java/vn/chuongpl/badbook/features/venue/Venue.java
git commit -m "feat: add venues table (V4 migration) and Venue entity"
```

---

### Task 11: Venue CRUD service + approval workflow

**Files:**
- Create: `src/main/java/vn/chuongpl/badbook/features/venue/VenueRepository.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/venue/dto/request/VenueCreateRequest.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/venue/dto/response/VenueResponse.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/venue/VenueMapper.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/venue/VenueService.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/venue/VenueController.java`
- Create: `src/test/java/vn/chuongpl/badbook/features/venue/VenueServiceTest.java`

- [ ] **Step 1: Create VenueRepository**

Create `src/main/java/vn/chuongpl/badbook/features/venue/VenueRepository.java`:
```java
package vn.chuongpl.badbook.features.venue;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import vn.chuongpl.badbook.common.enums.VenueStatus;
import vn.chuongpl.badbook.features.user.User;

import java.util.Optional;
import java.util.UUID;

public interface VenueRepository extends JpaRepository<Venue, UUID> {
    boolean existsByOwner(User owner);
    Optional<Venue> findByOwner(User owner);
    Page<Venue> findByStatus(VenueStatus status, Pageable pageable);
    Page<Venue> findByNameContainingIgnoreCaseAndStatus(String name, VenueStatus status, Pageable pageable);
}
```

- [ ] **Step 2: Create DTOs**

Create `src/main/java/vn/chuongpl/badbook/features/venue/dto/request/VenueCreateRequest.java`:
```java
package vn.chuongpl.badbook.features.venue.dto.request;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.math.BigDecimal;
import java.time.LocalTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class VenueCreateRequest {
    String name;
    String address;
    BigDecimal latitude;
    BigDecimal longitude;
    String description;
    String licenseId;
    LocalTime openTime;
    LocalTime closeTime;
    String bankName;
    String bankNumber;
    String bankAccountName;
}
```

Create `src/main/java/vn/chuongpl/badbook/features/venue/dto/response/VenueResponse.java`:
```java
package vn.chuongpl.badbook.features.venue.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.VenueStatus;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.UUID;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class VenueResponse {
    UUID id;
    String ownerName;
    String name;
    String address;
    BigDecimal latitude;
    BigDecimal longitude;
    String description;
    String licenseId;
    VenueStatus status;
    LocalTime openTime;
    LocalTime closeTime;
    BigDecimal platformFeeRate;
    LocalDateTime createdAt;
}
```

- [ ] **Step 3: Create VenueMapper**

Create `src/main/java/vn/chuongpl/badbook/features/venue/VenueMapper.java`:
```java
package vn.chuongpl.badbook.features.venue;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import vn.chuongpl.badbook.features.venue.dto.response.VenueResponse;

@Mapper(componentModel = "spring")
public interface VenueMapper {

    @Mapping(source = "owner.name", target = "ownerName")
    VenueResponse toResponse(Venue venue);
}
```

- [ ] **Step 4: Write failing test**

Create `src/test/java/vn/chuongpl/badbook/features/venue/VenueServiceTest.java`:
```java
package vn.chuongpl.badbook.features.venue;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import vn.chuongpl.badbook.common.enums.VenueStatus;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;
import vn.chuongpl.badbook.features.venue.dto.request.VenueCreateRequest;
import vn.chuongpl.badbook.features.venue.dto.response.VenueResponse;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class VenueServiceTest {

    @Mock VenueRepository venueRepository;
    @Mock UserRepository userRepository;
    @Mock VenueMapper venueMapper;
    @InjectMocks VenueService venueService;

    @Test
    void createVenue_successWhenUserHasNoVenue() {
        String userId = UUID.randomUUID().toString();
        User user = User.builder().id(UUID.fromString(userId)).name("Owner").build();
        when(userRepository.findById(any(UUID.class))).thenReturn(Optional.of(user));
        when(venueRepository.existsByOwner(user)).thenReturn(false);
        Venue saved = Venue.builder().id(UUID.randomUUID()).owner(user).status(VenueStatus.PENDING).build();
        when(venueRepository.save(any())).thenReturn(saved);
        when(venueMapper.toResponse(any())).thenReturn(VenueResponse.builder().status(VenueStatus.PENDING).build());

        VenueCreateRequest req = VenueCreateRequest.builder()
                .name("Sân cầu ABC").address("123 Đường ABC")
                .latitude(new BigDecimal("10.7769")).longitude(new BigDecimal("106.7009"))
                .licenseId("LIC001").openTime(LocalTime.of(6, 0)).closeTime(LocalTime.of(22, 0))
                .build();

        VenueResponse result = venueService.createVenue(userId, req);
        assertThat(result.getStatus()).isEqualTo(VenueStatus.PENDING);
    }

    @Test
    void createVenue_throwsWhenUserAlreadyHasVenue() {
        String userId = UUID.randomUUID().toString();
        User user = User.builder().id(UUID.fromString(userId)).build();
        when(userRepository.findById(any(UUID.class))).thenReturn(Optional.of(user));
        when(venueRepository.existsByOwner(user)).thenReturn(true);

        assertThatThrownBy(() -> venueService.createVenue(userId, new VenueCreateRequest()))
                .isInstanceOf(AppException.class);
    }

    @Test
    void approveVenue_changesStatusToActive() {
        UUID venueId = UUID.randomUUID();
        Venue venue = Venue.builder().id(venueId).status(VenueStatus.PENDING).build();
        when(venueRepository.findById(venueId)).thenReturn(Optional.of(venue));
        when(venueRepository.save(any())).thenAnswer(i -> i.getArgument(0));
        when(venueMapper.toResponse(any())).thenReturn(VenueResponse.builder().status(VenueStatus.ACTIVE).build());

        VenueResponse result = venueService.approveVenue(venueId.toString());
        assertThat(result.getStatus()).isEqualTo(VenueStatus.ACTIVE);
    }
}
```

- [ ] **Step 5: Run test — expect FAIL (VenueService not found)**
```bash
mvn test -Dtest=VenueServiceTest -q 2>&1 | tail -5
```

- [ ] **Step 6: Create VenueService**

Create `src/main/java/vn/chuongpl/badbook/features/venue/VenueService.java`:
```java
package vn.chuongpl.badbook.features.venue;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.chuongpl.badbook.common.PageResponse;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.enums.VenueStatus;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;
import vn.chuongpl.badbook.features.venue.dto.request.VenueCreateRequest;
import vn.chuongpl.badbook.features.venue.dto.response.VenueResponse;

import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class VenueService {

    VenueRepository venueRepository;
    UserRepository userRepository;
    VenueMapper venueMapper;

    @Transactional
    public VenueResponse createVenue(String userId, VenueCreateRequest request) {
        User owner = findUser(userId);
        if (venueRepository.existsByOwner(owner)) throw new AppException(ErrorCode.VENUE_ALREADY_EXISTS);
        Venue venue = Venue.builder()
                .owner(owner)
                .name(request.getName())
                .address(request.getAddress())
                .latitude(request.getLatitude())
                .longitude(request.getLongitude())
                .description(request.getDescription())
                .licenseId(request.getLicenseId())
                .openTime(request.getOpenTime())
                .closeTime(request.getCloseTime())
                .bankName(request.getBankName())
                .bankNumber(request.getBankNumber())
                .bankAccountName(request.getBankAccountName())
                .status(VenueStatus.PENDING)
                .build();
        return venueMapper.toResponse(venueRepository.save(venue));
    }

    public VenueResponse getVenueByOwner(String userId) {
        User owner = findUser(userId);
        Venue venue = venueRepository.findByOwner(owner)
                .orElseThrow(() -> new AppException(ErrorCode.VENUE_NOT_FOUND));
        return venueMapper.toResponse(venue);
    }

    public VenueResponse getVenueById(String venueId) {
        return venueMapper.toResponse(findVenue(venueId));
    }

    public PageResponse<VenueResponse> getActiveVenues(String keyword, int page, int size) {
        PageRequest pageable = PageRequest.of(page - 1, size, Sort.by("createdAt").descending());
        Page<Venue> result = (keyword != null && !keyword.isBlank())
                ? venueRepository.findByNameContainingIgnoreCaseAndStatus(keyword, VenueStatus.ACTIVE, pageable)
                : venueRepository.findByStatus(VenueStatus.ACTIVE, pageable);
        return buildPageResponse(result, page, size);
    }

    public PageResponse<VenueResponse> getPendingVenues(int page, int size) {
        Page<Venue> result = venueRepository.findByStatus(VenueStatus.PENDING,
                PageRequest.of(page - 1, size, Sort.by("createdAt").ascending()));
        return buildPageResponse(result, page, size);
    }

    @Transactional
    public VenueResponse approveVenue(String venueId) {
        return changeStatus(venueId, VenueStatus.ACTIVE);
    }

    @Transactional
    public VenueResponse rejectVenue(String venueId) {
        return changeStatus(venueId, VenueStatus.REJECTED);
    }

    @Transactional
    public VenueResponse suspendVenue(String venueId) {
        return changeStatus(venueId, VenueStatus.SUSPENDED);
    }

    @Transactional
    public VenueResponse updateBannerIds(String venueId, String ownerId, String bannerIds) {
        Venue venue = findVenue(venueId);
        User owner = findUser(ownerId);
        if (!venue.getOwner().getId().equals(owner.getId())) throw new AppException(ErrorCode.VENUE_NOT_OWNED_BY_USER);
        venue.setBannerIds(bannerIds);
        return venueMapper.toResponse(venueRepository.save(venue));
    }

    private VenueResponse changeStatus(String venueId, VenueStatus status) {
        Venue venue = findVenue(venueId);
        venue.setStatus(status);
        return venueMapper.toResponse(venueRepository.save(venue));
    }

    private Venue findVenue(String venueId) {
        try {
            return venueRepository.findById(UUID.fromString(venueId))
                    .orElseThrow(() -> new AppException(ErrorCode.VENUE_NOT_FOUND));
        } catch (IllegalArgumentException e) {
            throw new AppException(ErrorCode.ID_INVALID);
        }
    }

    private User findUser(String userId) {
        try {
            return userRepository.findById(UUID.fromString(userId))
                    .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
        } catch (IllegalArgumentException e) {
            throw new AppException(ErrorCode.ID_INVALID);
        }
    }

    private PageResponse<VenueResponse> buildPageResponse(Page<Venue> page, int pageNum, int size) {
        return PageResponse.<VenueResponse>builder()
                .items(page.getContent().stream().map(venueMapper::toResponse).toList())
                .total(page.getTotalElements())
                .page(pageNum)
                .pageSize(size)
                .totalPages(page.getTotalPages())
                .build();
    }
}
```

- [ ] **Step 7: Create VenueController**

Create `src/main/java/vn/chuongpl/badbook/features/venue/VenueController.java`:
```java
package vn.chuongpl.badbook.features.venue;

import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.common.PageResponse;
import vn.chuongpl.badbook.features.venue.dto.request.VenueCreateRequest;
import vn.chuongpl.badbook.features.venue.dto.response.VenueResponse;

@RestController
@RequestMapping("/api/venues")
@RequiredArgsConstructor
public class VenueController {

    private final VenueService venueService;

    @PostMapping
    @PreAuthorize("hasRole('VENUE_MANAGER')")
    public ApiResponse<VenueResponse> createVenue(@AuthenticationPrincipal Jwt jwt,
                                                   @RequestBody VenueCreateRequest request) {
        return ApiResponse.<VenueResponse>builder()
                .data(venueService.createVenue(jwt.getSubject(), request)).build();
    }

    @GetMapping("/my")
    @PreAuthorize("hasRole('VENUE_MANAGER')")
    public ApiResponse<VenueResponse> getMyVenue(@AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.<VenueResponse>builder()
                .data(venueService.getVenueByOwner(jwt.getSubject())).build();
    }

    @GetMapping
    public ApiResponse<PageResponse<VenueResponse>> getActiveVenues(
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ApiResponse.<PageResponse<VenueResponse>>builder()
                .data(venueService.getActiveVenues(keyword, page, size)).build();
    }

    @GetMapping("/{id}")
    public ApiResponse<VenueResponse> getVenue(@PathVariable String id) {
        return ApiResponse.<VenueResponse>builder()
                .data(venueService.getVenueById(id)).build();
    }

    @PutMapping("/{id}/approve")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<VenueResponse> approve(@PathVariable String id) {
        return ApiResponse.<VenueResponse>builder()
                .data(venueService.approveVenue(id)).build();
    }

    @PutMapping("/{id}/reject")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<VenueResponse> reject(@PathVariable String id) {
        return ApiResponse.<VenueResponse>builder()
                .data(venueService.rejectVenue(id)).build();
    }

    @PutMapping("/{id}/suspend")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<VenueResponse> suspend(@PathVariable String id) {
        return ApiResponse.<VenueResponse>builder()
                .data(venueService.suspendVenue(id)).build();
    }

    @GetMapping("/pending")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<PageResponse<VenueResponse>> getPending(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ApiResponse.<PageResponse<VenueResponse>>builder()
                .data(venueService.getPendingVenues(page, size)).build();
    }
}
```

- [ ] **Step 8: Run tests — expect PASS**
```bash
mvn test -Dtest=VenueServiceTest -q 2>&1 | tail -5
```

- [ ] **Step 9: Commit**
```bash
git add src/main/java/vn/chuongpl/badbook/features/venue/
git add src/test/java/vn/chuongpl/badbook/features/venue/
git commit -m "feat: add Venue CRUD with approval workflow for ADMIN"
```

---

### Task 12: Court entity + Flyway V5 + Court CRUD

**Files:**
- Create: `src/main/resources/db/migration/V5__create_courts_table.sql`
- Create: `src/main/java/vn/chuongpl/badbook/features/court/Court.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/court/CourtRepository.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/court/dto/request/CourtCreateRequest.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/court/dto/response/CourtResponse.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/court/CourtMapper.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/court/CourtService.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/court/CourtController.java`
- Create: `src/test/java/vn/chuongpl/badbook/features/court/CourtServiceTest.java`

- [ ] **Step 1: Create V5 migration**

`src/main/resources/db/migration/V5__create_courts_table.sql`:
```sql
CREATE TABLE courts (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    venue_id    UUID NOT NULL REFERENCES venues(id) ON DELETE CASCADE,
    name        VARCHAR(100) NOT NULL,
    court_type  VARCHAR(20) NOT NULL DEFAULT 'STANDARD'
                    CHECK (court_type IN ('STANDARD','PREMIUM','VIP')),
    price_per_hour DECIMAL(12,2) NOT NULL CHECK (price_per_hour >= 0),
    image_ids   TEXT,
    status      VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
                    CHECK (status IN ('ACTIVE','MAINTENANCE','INACTIVE')),
    description TEXT
);

CREATE INDEX idx_courts_venue ON courts(venue_id);
CREATE INDEX idx_courts_status ON courts(status);
```

- [ ] **Step 2: Create Court entity**

`src/main/java/vn/chuongpl/badbook/features/court/Court.java`:
```java
package vn.chuongpl.badbook.features.court;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.CourtStatus;
import vn.chuongpl.badbook.common.enums.CourtType;
import vn.chuongpl.badbook.features.venue.Venue;

import java.math.BigDecimal;
import java.util.UUID;

@Entity @Table(name = "courts")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class Court {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid") UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "venue_id", nullable = false) Venue venue;

    @Column(nullable = false) String name;

    @Enumerated(EnumType.STRING)
    @Column(name = "court_type", nullable = false, length = 20)
    @Builder.Default CourtType courtType = CourtType.STANDARD;

    @Column(name = "price_per_hour", nullable = false, precision = 12, scale = 2)
    BigDecimal pricePerHour;

    @Column(name = "image_ids") String imageIds;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default CourtStatus status = CourtStatus.ACTIVE;

    @Column(columnDefinition = "TEXT") String description;
}
```

- [ ] **Step 3: Create CourtRepository**

`src/main/java/vn/chuongpl/badbook/features/court/CourtRepository.java`:
```java
package vn.chuongpl.badbook.features.court;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.chuongpl.badbook.common.enums.CourtStatus;
import vn.chuongpl.badbook.features.venue.Venue;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface CourtRepository extends JpaRepository<Court, UUID> {
    List<Court> findByVenueAndStatus(Venue venue, CourtStatus status);
    List<Court> findByVenue(Venue venue);
    Optional<Court> findByIdAndVenue(UUID id, Venue venue);
}
```

- [ ] **Step 4: Create DTOs**

`src/main/java/vn/chuongpl/badbook/features/court/dto/request/CourtCreateRequest.java`:
```java
package vn.chuongpl.badbook.features.court.dto.request;

import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.CourtType;

import java.math.BigDecimal;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class CourtCreateRequest {
    String name;
    CourtType courtType;
    BigDecimal pricePerHour;
    String description;
}
```

`src/main/java/vn/chuongpl/badbook/features/court/dto/response/CourtResponse.java`:
```java
package vn.chuongpl.badbook.features.court.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.CourtStatus;
import vn.chuongpl.badbook.common.enums.CourtType;

import java.math.BigDecimal;
import java.util.UUID;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class CourtResponse {
    UUID id;
    UUID venueId;
    String venueName;
    String name;
    CourtType courtType;
    BigDecimal pricePerHour;
    CourtStatus status;
    String description;
}
```

- [ ] **Step 5: Create CourtMapper**

`src/main/java/vn/chuongpl/badbook/features/court/CourtMapper.java`:
```java
package vn.chuongpl.badbook.features.court;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import vn.chuongpl.badbook.features.court.dto.response.CourtResponse;

@Mapper(componentModel = "spring")
public interface CourtMapper {
    @Mapping(source = "venue.id", target = "venueId")
    @Mapping(source = "venue.name", target = "venueName")
    CourtResponse toResponse(Court court);
}
```

- [ ] **Step 6: Write failing test**

`src/test/java/vn/chuongpl/badbook/features/court/CourtServiceTest.java`:
```java
package vn.chuongpl.badbook.features.court;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import vn.chuongpl.badbook.common.enums.CourtStatus;
import vn.chuongpl.badbook.common.enums.CourtType;
import vn.chuongpl.badbook.common.enums.VenueStatus;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.court.dto.request.CourtCreateRequest;
import vn.chuongpl.badbook.features.court.dto.response.CourtResponse;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;
import vn.chuongpl.badbook.features.venue.Venue;
import vn.chuongpl.badbook.features.venue.VenueRepository;

import java.math.BigDecimal;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class CourtServiceTest {

    @Mock CourtRepository courtRepository;
    @Mock VenueRepository venueRepository;
    @Mock UserRepository userRepository;
    @Mock CourtMapper courtMapper;
    @InjectMocks CourtService courtService;

    @Test
    void createCourt_successForActiveVenueOwner() {
        UUID userId = UUID.randomUUID();
        UUID venueId = UUID.randomUUID();
        User owner = User.builder().id(userId).build();
        Venue venue = Venue.builder().id(venueId).owner(owner).status(VenueStatus.ACTIVE).build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(owner));
        when(venueRepository.findById(venueId)).thenReturn(Optional.of(venue));
        Court saved = Court.builder().id(UUID.randomUUID()).venue(venue).build();
        when(courtRepository.save(any())).thenReturn(saved);
        when(courtMapper.toResponse(any())).thenReturn(CourtResponse.builder().courtType(CourtType.STANDARD).build());

        CourtCreateRequest req = CourtCreateRequest.builder()
                .name("Sân A1").courtType(CourtType.STANDARD).pricePerHour(new BigDecimal("80000")).build();

        CourtResponse result = courtService.createCourt(userId.toString(), venueId.toString(), req);
        assertThat(result.getCourtType()).isEqualTo(CourtType.STANDARD);
    }

    @Test
    void createCourt_throwsWhenVenueNotOwnedByUser() {
        UUID userId = UUID.randomUUID();
        UUID venueId = UUID.randomUUID();
        User owner = User.builder().id(UUID.randomUUID()).build(); // different user
        Venue venue = Venue.builder().id(venueId).owner(owner).status(VenueStatus.ACTIVE).build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(User.builder().id(userId).build()));
        when(venueRepository.findById(venueId)).thenReturn(Optional.of(venue));

        assertThatThrownBy(() -> courtService.createCourt(userId.toString(), venueId.toString(), new CourtCreateRequest()))
                .isInstanceOf(AppException.class);
    }
}
```

- [ ] **Step 7: Run test — expect FAIL**
```bash
mvn test -Dtest=CourtServiceTest -q 2>&1 | tail -5
```

- [ ] **Step 8: Create CourtService**

`src/main/java/vn/chuongpl/badbook/features/court/CourtService.java`:
```java
package vn.chuongpl.badbook.features.court;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.chuongpl.badbook.common.enums.CourtStatus;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.enums.VenueStatus;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.court.dto.request.CourtCreateRequest;
import vn.chuongpl.badbook.features.court.dto.response.CourtResponse;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;
import vn.chuongpl.badbook.features.venue.Venue;
import vn.chuongpl.badbook.features.venue.VenueRepository;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class CourtService {

    CourtRepository courtRepository;
    VenueRepository venueRepository;
    UserRepository userRepository;
    CourtMapper courtMapper;

    @Transactional
    public CourtResponse createCourt(String userId, String venueId, CourtCreateRequest request) {
        User user = findUser(userId);
        Venue venue = findVenue(venueId);
        assertOwner(venue, user);
        if (venue.getStatus() != VenueStatus.ACTIVE) throw new AppException(ErrorCode.VENUE_NOT_APPROVED);

        Court court = Court.builder()
                .venue(venue)
                .name(request.getName())
                .courtType(request.getCourtType())
                .pricePerHour(request.getPricePerHour())
                .description(request.getDescription())
                .status(CourtStatus.ACTIVE)
                .build();
        return courtMapper.toResponse(courtRepository.save(court));
    }

    public List<CourtResponse> getCourtsByVenue(String venueId) {
        Venue venue = findVenue(venueId);
        return courtRepository.findByVenueAndStatus(venue, CourtStatus.ACTIVE)
                .stream().map(courtMapper::toResponse).toList();
    }

    public CourtResponse getCourtById(String courtId) {
        return courtMapper.toResponse(findCourt(courtId));
    }

    @Transactional
    public CourtResponse setStatus(String userId, String venueId, String courtId, CourtStatus status) {
        User user = findUser(userId);
        Venue venue = findVenue(venueId);
        assertOwner(venue, user);
        Court court = courtRepository.findByIdAndVenue(UUID.fromString(courtId), venue)
                .orElseThrow(() -> new AppException(ErrorCode.COURT_NOT_IN_VENUE));
        court.setStatus(status);
        return courtMapper.toResponse(courtRepository.save(court));
    }

    @Transactional
    public CourtResponse updateImageIds(String userId, String venueId, String courtId, String imageIds) {
        User user = findUser(userId);
        Venue venue = findVenue(venueId);
        assertOwner(venue, user);
        Court court = courtRepository.findByIdAndVenue(UUID.fromString(courtId), venue)
                .orElseThrow(() -> new AppException(ErrorCode.COURT_NOT_IN_VENUE));
        court.setImageIds(imageIds);
        return courtMapper.toResponse(courtRepository.save(court));
    }

    private void assertOwner(Venue venue, User user) {
        if (!venue.getOwner().getId().equals(user.getId()))
            throw new AppException(ErrorCode.VENUE_NOT_OWNED_BY_USER);
    }

    Court findCourt(String courtId) {
        try {
            return courtRepository.findById(UUID.fromString(courtId))
                    .orElseThrow(() -> new AppException(ErrorCode.COURT_NOT_FOUND));
        } catch (IllegalArgumentException e) { throw new AppException(ErrorCode.ID_INVALID); }
    }

    private Venue findVenue(String venueId) {
        try {
            return venueRepository.findById(UUID.fromString(venueId))
                    .orElseThrow(() -> new AppException(ErrorCode.VENUE_NOT_FOUND));
        } catch (IllegalArgumentException e) { throw new AppException(ErrorCode.ID_INVALID); }
    }

    private User findUser(String userId) {
        try {
            return userRepository.findById(UUID.fromString(userId))
                    .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
        } catch (IllegalArgumentException e) { throw new AppException(ErrorCode.ID_INVALID); }
    }
}
```

- [ ] **Step 9: Create CourtController**

`src/main/java/vn/chuongpl/badbook/features/court/CourtController.java`:
```java
package vn.chuongpl.badbook.features.court;

import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.common.enums.CourtStatus;
import vn.chuongpl.badbook.features.court.dto.request.CourtCreateRequest;
import vn.chuongpl.badbook.features.court.dto.response.CourtResponse;

import java.util.List;

@RestController
@RequestMapping("/api/venues/{venueId}/courts")
@RequiredArgsConstructor
public class CourtController {

    private final CourtService courtService;

    @PostMapping
    @PreAuthorize("hasRole('VENUE_MANAGER')")
    public ApiResponse<CourtResponse> createCourt(@AuthenticationPrincipal Jwt jwt,
                                                    @PathVariable String venueId,
                                                    @RequestBody CourtCreateRequest request) {
        return ApiResponse.<CourtResponse>builder()
                .data(courtService.createCourt(jwt.getSubject(), venueId, request)).build();
    }

    @GetMapping
    public ApiResponse<List<CourtResponse>> getCourts(@PathVariable String venueId) {
        return ApiResponse.<List<CourtResponse>>builder()
                .data(courtService.getCourtsByVenue(venueId)).build();
    }

    @GetMapping("/{courtId}")
    public ApiResponse<CourtResponse> getCourt(@PathVariable String venueId,
                                                @PathVariable String courtId) {
        return ApiResponse.<CourtResponse>builder()
                .data(courtService.getCourtById(courtId)).build();
    }

    @PutMapping("/{courtId}/status")
    @PreAuthorize("hasRole('VENUE_MANAGER')")
    public ApiResponse<CourtResponse> setStatus(@AuthenticationPrincipal Jwt jwt,
                                                 @PathVariable String venueId,
                                                 @PathVariable String courtId,
                                                 @RequestParam CourtStatus status) {
        return ApiResponse.<CourtResponse>builder()
                .data(courtService.setStatus(jwt.getSubject(), venueId, courtId, status)).build();
    }
}
```

- [ ] **Step 10: Run tests — expect PASS**
```bash
mvn test -Dtest=CourtServiceTest -q 2>&1 | tail -5
```

- [ ] **Step 11: Commit**
```bash
git add src/main/resources/db/migration/V5__create_courts_table.sql
git add src/main/java/vn/chuongpl/badbook/features/court/
git add src/test/java/vn/chuongpl/badbook/features/court/
git commit -m "feat: add Court entity, CRUD and status management (V5 migration)"
```

---

### Task 13: Product entity + Flyway V6 + Product CRUD

**Files:**
- Create: `src/main/resources/db/migration/V6__create_products_table.sql`
- Create: `src/main/java/vn/chuongpl/badbook/features/product/Product.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/product/ProductRepository.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/product/dto/request/ProductCreateRequest.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/product/dto/response/ProductResponse.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/product/ProductMapper.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/product/ProductService.java`
- Create: `src/main/java/vn/chuongpl/badbook/features/product/ProductController.java`
- Create: `src/test/java/vn/chuongpl/badbook/features/product/ProductServiceTest.java`

- [ ] **Step 1: Create V6 migration**

`src/main/resources/db/migration/V6__create_products_table.sql`:
```sql
CREATE TABLE products (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    venue_id    UUID NOT NULL REFERENCES venues(id) ON DELETE CASCADE,
    name        VARCHAR(255) NOT NULL,
    description TEXT,
    category    VARCHAR(30) NOT NULL DEFAULT 'OTHER'
                    CHECK (category IN ('RACKET_RENTAL','SHUTTLECOCK','BEVERAGE','EQUIPMENT','OTHER')),
    price       DECIMAL(12,2) NOT NULL CHECK (price >= 0),
    unit        VARCHAR(50) NOT NULL DEFAULT 'cái',
    stock       INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    image_id    VARCHAR(255),
    is_active   BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX idx_products_venue ON products(venue_id);
```

- [ ] **Step 2: Create Product entity**

`src/main/java/vn/chuongpl/badbook/features/product/Product.java`:
```java
package vn.chuongpl.badbook.features.product;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.ProductCategory;
import vn.chuongpl.badbook.features.venue.Venue;

import java.math.BigDecimal;
import java.util.UUID;

@Entity @Table(name = "products")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class Product {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid") UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "venue_id", nullable = false) Venue venue;

    @Column(nullable = false) String name;
    @Column(columnDefinition = "TEXT") String description;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    @Builder.Default ProductCategory category = ProductCategory.OTHER;

    @Column(nullable = false, precision = 12, scale = 2) BigDecimal price;
    @Column(nullable = false) @Builder.Default String unit = "cái";
    @Column(nullable = false) @Builder.Default int stock = 0;
    @Column(name = "image_id") String imageId;
    @Column(name = "is_active") @Builder.Default boolean active = true;
}
```

- [ ] **Step 3: Create ProductRepository**

`src/main/java/vn/chuongpl/badbook/features/product/ProductRepository.java`:
```java
package vn.chuongpl.badbook.features.product;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.chuongpl.badbook.features.venue.Venue;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ProductRepository extends JpaRepository<Product, UUID> {
    List<Product> findByVenueAndActiveTrue(Venue venue);
    Optional<Product> findByIdAndVenue(UUID id, Venue venue);
}
```

- [ ] **Step 4: Create DTOs**

`src/main/java/vn/chuongpl/badbook/features/product/dto/request/ProductCreateRequest.java`:
```java
package vn.chuongpl.badbook.features.product.dto.request;

import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.ProductCategory;

import java.math.BigDecimal;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ProductCreateRequest {
    String name;
    String description;
    ProductCategory category;
    BigDecimal price;
    String unit;
    int stock;
}
```

`src/main/java/vn/chuongpl/badbook/features/product/dto/response/ProductResponse.java`:
```java
package vn.chuongpl.badbook.features.product.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.ProductCategory;

import java.math.BigDecimal;
import java.util.UUID;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ProductResponse {
    UUID id;
    UUID venueId;
    String name;
    String description;
    ProductCategory category;
    BigDecimal price;
    String unit;
    int stock;
    boolean active;
}
```

- [ ] **Step 5: Create ProductMapper**

`src/main/java/vn/chuongpl/badbook/features/product/ProductMapper.java`:
```java
package vn.chuongpl.badbook.features.product;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import vn.chuongpl.badbook.features.product.dto.response.ProductResponse;

@Mapper(componentModel = "spring")
public interface ProductMapper {
    @Mapping(source = "venue.id", target = "venueId")
    ProductResponse toResponse(Product product);
}
```

- [ ] **Step 6: Write failing test**

`src/test/java/vn/chuongpl/badbook/features/product/ProductServiceTest.java`:
```java
package vn.chuongpl.badbook.features.product;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.product.dto.request.ProductCreateRequest;
import vn.chuongpl.badbook.features.product.dto.response.ProductResponse;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;
import vn.chuongpl.badbook.features.venue.Venue;
import vn.chuongpl.badbook.features.venue.VenueRepository;

import java.math.BigDecimal;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ProductServiceTest {

    @Mock ProductRepository productRepository;
    @Mock VenueRepository venueRepository;
    @Mock UserRepository userRepository;
    @Mock ProductMapper productMapper;
    @InjectMocks ProductService productService;

    @Test
    void addProduct_successForOwner() {
        UUID userId = UUID.randomUUID(), venueId = UUID.randomUUID();
        User owner = User.builder().id(userId).build();
        Venue venue = Venue.builder().id(venueId).owner(owner).build();
        when(userRepository.findById(userId)).thenReturn(Optional.of(owner));
        when(venueRepository.findById(venueId)).thenReturn(Optional.of(venue));
        when(productRepository.save(any())).thenAnswer(i -> i.getArgument(0));
        when(productMapper.toResponse(any())).thenReturn(ProductResponse.builder().name("Vợt A").build());

        ProductResponse result = productService.addProduct(userId.toString(), venueId.toString(),
                ProductCreateRequest.builder().name("Vợt A").price(new BigDecimal("50000")).unit("cái").stock(10).build());
        assertThat(result.getName()).isEqualTo("Vợt A");
    }

    @Test
    void decreaseStock_throwsWhenOutOfStock() {
        UUID productId = UUID.randomUUID(), venueId = UUID.randomUUID();
        Venue venue = Venue.builder().id(venueId).build();
        Product product = Product.builder().id(productId).venue(venue).stock(0).build();
        when(venueRepository.findById(venueId)).thenReturn(Optional.of(venue));
        when(productRepository.findByIdAndVenue(productId, venue)).thenReturn(Optional.of(product));

        assertThatThrownBy(() -> productService.decreaseStock(venueId.toString(), productId.toString(), 1))
                .isInstanceOf(AppException.class);
    }
}
```

- [ ] **Step 7: Run test — expect FAIL**
```bash
mvn test -Dtest=ProductServiceTest -q 2>&1 | tail -5
```

- [ ] **Step 8: Create ProductService**

`src/main/java/vn/chuongpl/badbook/features/product/ProductService.java`:
```java
package vn.chuongpl.badbook.features.product;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.product.dto.request.ProductCreateRequest;
import vn.chuongpl.badbook.features.product.dto.response.ProductResponse;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;
import vn.chuongpl.badbook.features.venue.Venue;
import vn.chuongpl.badbook.features.venue.VenueRepository;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class ProductService {

    ProductRepository productRepository;
    VenueRepository venueRepository;
    UserRepository userRepository;
    ProductMapper productMapper;

    @Transactional
    public ProductResponse addProduct(String userId, String venueId, ProductCreateRequest request) {
        User user = findUser(userId);
        Venue venue = findVenue(venueId);
        assertOwner(venue, user);
        Product product = Product.builder()
                .venue(venue).name(request.getName()).description(request.getDescription())
                .category(request.getCategory()).price(request.getPrice())
                .unit(request.getUnit()).stock(request.getStock()).build();
        return productMapper.toResponse(productRepository.save(product));
    }

    public List<ProductResponse> getProductsByVenue(String venueId) {
        return productRepository.findByVenueAndActiveTrue(findVenue(venueId))
                .stream().map(productMapper::toResponse).toList();
    }

    @Transactional
    public void decreaseStock(String venueId, String productId, int quantity) {
        Venue venue = findVenue(venueId);
        Product product = productRepository.findByIdAndVenue(UUID.fromString(productId), venue)
                .orElseThrow(() -> new AppException(ErrorCode.PRODUCT_NOT_FOUND));
        if (product.getStock() < quantity) throw new AppException(ErrorCode.PRODUCT_OUT_OF_STOCK);
        product.setStock(product.getStock() - quantity);
        productRepository.save(product);
    }

    @Transactional
    public void increaseStock(String venueId, String productId, int quantity) {
        Venue venue = findVenue(venueId);
        Product product = productRepository.findByIdAndVenue(UUID.fromString(productId), venue)
                .orElseThrow(() -> new AppException(ErrorCode.PRODUCT_NOT_FOUND));
        product.setStock(product.getStock() + quantity);
        productRepository.save(product);
    }

    Product findProduct(String productId) {
        return productRepository.findById(UUID.fromString(productId))
                .orElseThrow(() -> new AppException(ErrorCode.PRODUCT_NOT_FOUND));
    }

    private void assertOwner(Venue venue, User user) {
        if (!venue.getOwner().getId().equals(user.getId()))
            throw new AppException(ErrorCode.VENUE_NOT_OWNED_BY_USER);
    }

    private Venue findVenue(String venueId) {
        return venueRepository.findById(UUID.fromString(venueId))
                .orElseThrow(() -> new AppException(ErrorCode.VENUE_NOT_FOUND));
    }

    private User findUser(String userId) {
        return userRepository.findById(UUID.fromString(userId))
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
    }
}
```

- [ ] **Step 9: Create ProductController**

`src/main/java/vn/chuongpl/badbook/features/product/ProductController.java`:
```java
package vn.chuongpl.badbook.features.product;

import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.features.product.dto.request.ProductCreateRequest;
import vn.chuongpl.badbook.features.product.dto.response.ProductResponse;

import java.util.List;

@RestController
@RequestMapping("/api/venues/{venueId}/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    @PostMapping
    @PreAuthorize("hasRole('VENUE_MANAGER')")
    public ApiResponse<ProductResponse> addProduct(@AuthenticationPrincipal Jwt jwt,
                                                    @PathVariable String venueId,
                                                    @RequestBody ProductCreateRequest request) {
        return ApiResponse.<ProductResponse>builder()
                .data(productService.addProduct(jwt.getSubject(), venueId, request)).build();
    }

    @GetMapping
    public ApiResponse<List<ProductResponse>> getProducts(@PathVariable String venueId) {
        return ApiResponse.<List<ProductResponse>>builder()
                .data(productService.getProductsByVenue(venueId)).build();
    }
}
```

- [ ] **Step 10: Run tests — expect PASS**
```bash
mvn test -Dtest=ProductServiceTest -q 2>&1 | tail -5
```

- [ ] **Step 11: Full test suite**
```bash
mvn test -q 2>&1 | tail -10
```
Expected: BUILD SUCCESS, no test failures.

- [ ] **Step 12: Commit Phase 2**
```bash
git add src/main/resources/db/migration/V6__create_products_table.sql
git add src/main/java/vn/chuongpl/badbook/features/product/
git add src/test/java/vn/chuongpl/badbook/features/product/
git commit -m "feat: add Product catalog management for venues (V6 migration)"
git tag phase-2-complete
git commit --allow-empty -m "chore: Phase 2 Venue & Court Management complete"
```
