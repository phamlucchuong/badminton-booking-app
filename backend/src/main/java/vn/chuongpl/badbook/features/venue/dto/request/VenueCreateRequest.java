package vn.chuongpl.badbook.features.venue.dto.request;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.math.BigDecimal;
import java.time.LocalTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class VenueCreateRequest {
    String name;
    String address;
    BigDecimal latitude;
    BigDecimal longitude;
    String description;
    String licenseId;
    LocalTime openTime;
    LocalTime closeTime;
    String bankName;
    String bankNumber;
    String bankAccountName;
}
