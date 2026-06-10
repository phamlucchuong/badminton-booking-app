package vn.chuongpl.badbook.configuration;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
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
