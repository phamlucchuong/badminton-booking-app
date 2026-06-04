package vn.chuongpl.badbook.features.booking.dto.request;

import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.BookingType;
import vn.chuongpl.badbook.common.enums.PaymentMethod;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class BookingCreateRequest {
    String courtId;
    String venueId;
    LocalDate bookingDate;
    LocalTime startTime;
    LocalTime endTime;
    BookingType type;
    PaymentMethod paymentMethod;
    String notes;
    List<AddProductRequest> products;
}
