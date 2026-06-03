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
