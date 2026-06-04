package vn.chuongpl.badbook.features.court.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.CourtStatus;
import vn.chuongpl.badbook.common.enums.CourtType;

import java.math.BigDecimal;
import java.util.UUID;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class CourtResponse {
    UUID id;
    UUID venueId;
    String venueName;
    String name;
    CourtType courtType;
    BigDecimal pricePerHour;
    CourtStatus status;
    String description;
}
