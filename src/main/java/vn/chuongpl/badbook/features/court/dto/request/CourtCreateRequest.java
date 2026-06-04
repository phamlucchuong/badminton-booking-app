package vn.chuongpl.badbook.features.court.dto.request;

import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.CourtType;

import java.math.BigDecimal;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class CourtCreateRequest {
    String name;
    CourtType courtType;
    BigDecimal pricePerHour;
    String description;
}
