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
    INVALID_PASSWORD(2005, "Mật khẩu hiện tại không đúng"),
    INVALID_TOKEN(2006, "Token không hợp lệ hoặc đã hết hạn"),
    GOOGLE_TOKEN_INVALID(2007, "Google ID token không hợp lệ"),
    GOOGLE_TOKEN_AUDIENCE_MISMATCH(2008, "Google token audience không khớp"),

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
