package vn.chuongpl.badbook.features.payment;

import lombok.AccessLevel;
import lombok.NonFinal;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.chuongpl.badbook.common.enums.BookingStatus;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.enums.PaymentMethod;
import vn.chuongpl.badbook.common.enums.PaymentStatus;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.booking.Booking;
import vn.chuongpl.badbook.features.booking.BookingRepository;
import vn.chuongpl.badbook.features.booking.BookingService;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class VNPayService {

    PaymentRepository paymentRepository;
    BookingRepository bookingRepository;
    BookingService bookingService;

    @NonFinal
    @Value("${vnpay.tmnCode:TESTCODE}")
    String tmnCode;

    @NonFinal
    @Value("${vnpay.secretKey:testsecretkey12345678901234567890}")
    String secretKey;

    @NonFinal
    @Value("${vnpay.payUrl}")
    String payUrl;

    @NonFinal
    @Value("${vnpay.returnUrl}")
    String returnUrl;

    public String createPaymentUrl(String bookingId, String ipAddress) {
        Booking booking = bookingService.findBooking(bookingId);
        if (booking.getStatus() != BookingStatus.PENDING)
            throw new AppException(ErrorCode.PAYMENT_ALREADY_PROCESSED);

        long amount = booking.getTotalAmount().longValue() * 100;
        String txnRef = bookingId.replace("-", "").substring(0, 16);
        String createDate = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());

        Map<String, String> params = new TreeMap<>();
        params.put("vnp_Version", "2.1.0");
        params.put("vnp_Command", "pay");
        params.put("vnp_TmnCode", tmnCode);
        params.put("vnp_Amount", String.valueOf(amount));
        params.put("vnp_CurrCode", "VND");
        params.put("vnp_TxnRef", txnRef);
        params.put("vnp_OrderInfo", "Thanh toan dat san " + bookingId);
        params.put("vnp_OrderType", "other");
        params.put("vnp_Locale", "vn");
        params.put("vnp_ReturnUrl", returnUrl + "?bookingId=" + bookingId);
        params.put("vnp_IpAddr", ipAddress);
        params.put("vnp_CreateDate", createDate);

        StringBuilder query = new StringBuilder();
        StringBuilder hashData = new StringBuilder();
        for (Map.Entry<String, String> e : params.entrySet()) {
            String enc = URLEncoder.encode(e.getValue(), StandardCharsets.US_ASCII);
            query.append(URLEncoder.encode(e.getKey(), StandardCharsets.US_ASCII)).append("=").append(enc).append("&");
            hashData.append(e.getKey()).append("=").append(e.getValue()).append("&");
        }
        String hash = hmacSHA512(secretKey, hashData.substring(0, hashData.length() - 1));
        return payUrl + "?" + query + "vnp_SecureHash=" + hash;
    }

    @Transactional
    public Payment handleCallback(String bookingId, String transactionId, String responseCode) {
        Booking booking = bookingService.findBooking(bookingId);
        if (paymentRepository.findByBooking(booking).isPresent())
            throw new AppException(ErrorCode.PAYMENT_ALREADY_PROCESSED);

        boolean success = "00".equals(responseCode);
        Payment payment = paymentRepository.save(Payment.builder()
                .booking(booking).amount(booking.getTotalAmount())
                .method(PaymentMethod.VNPAY).transactionId(transactionId)
                .status(success ? PaymentStatus.SUCCESS : PaymentStatus.FAILED)
                .paidAt(success ? java.time.LocalDateTime.now() : null).build());

        if (success) {
            booking.setStatus(BookingStatus.CONFIRMED);
            bookingRepository.save(booking);
        }
        return payment;
    }

    private String hmacSHA512(String key, String data) {
        try {
            Mac mac = Mac.getInstance("HmacSHA512");
            mac.init(new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA512"));
            byte[] bytes = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) { throw new RuntimeException(e); }
    }
}
