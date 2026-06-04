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
