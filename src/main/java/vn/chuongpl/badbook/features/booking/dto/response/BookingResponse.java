package vn.chuongpl.badbook.features.booking.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.BookingStatus;
import vn.chuongpl.badbook.common.enums.BookingType;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class BookingResponse {
    UUID id;
    String userName;
    String courtName;
    String venueName;
    LocalDate bookingDate;
    LocalTime startTime;
    LocalTime endTime;
    BookingType type;
    BookingStatus status;
    BigDecimal totalAmount;
    String notes;
    String cancelReason;
    LocalDateTime createdAt;
    List<BookingProductResponse> products;

    @Data @Builder @NoArgsConstructor @AllArgsConstructor
    public static class BookingProductResponse {
        String productName;
        int quantity;
        BigDecimal unitPrice;
        BigDecimal totalPrice;
    }
}
