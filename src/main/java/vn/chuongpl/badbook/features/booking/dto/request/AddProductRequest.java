package vn.chuongpl.badbook.features.booking.dto.request;

import lombok.*;
import lombok.experimental.FieldDefaults;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class AddProductRequest {
    String productId;
    int quantity;
}
