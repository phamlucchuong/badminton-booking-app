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
