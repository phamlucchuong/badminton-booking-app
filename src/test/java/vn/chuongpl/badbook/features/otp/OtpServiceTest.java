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
