package vn.chuongpl.badbook.features.payment;

import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import vn.chuongpl.badbook.common.ApiResponse;

@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final VNPayService vnPayService;

    @PostMapping("/vnpay/create")
    @PreAuthorize("hasRole('USER')")
    public ApiResponse<String> createPayment(@RequestParam String bookingId,
                                              HttpServletRequest request) {
        String ip = request.getRemoteAddr();
        return ApiResponse.<String>builder()
                .data(vnPayService.createPaymentUrl(bookingId, ip)).build();
    }

    @GetMapping("/vnpay-callback")
    public ApiResponse<Payment> vnpayCallback(@RequestParam String bookingId,
                                               @RequestParam String vnp_TxnRef,
                                               @RequestParam String vnp_ResponseCode) {
        return ApiResponse.<Payment>builder()
                .data(vnPayService.handleCallback(bookingId, vnp_TxnRef, vnp_ResponseCode)).build();
    }
}
