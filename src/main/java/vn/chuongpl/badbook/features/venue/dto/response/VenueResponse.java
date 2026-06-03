package vn.chuongpl.badbook.features.venue.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.VenueStatus;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.UUID;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class VenueResponse {
    UUID id;
    String ownerName;
    String name;
    String address;
    BigDecimal latitude;
    BigDecimal longitude;
    String description;
    String licenseId;
    VenueStatus status;
    LocalTime openTime;
    LocalTime closeTime;
    BigDecimal platformFeeRate;
    LocalDateTime createdAt;
}
