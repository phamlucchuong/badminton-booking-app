package vn.chuongpl.badbook.features.product.dto.response;

import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.ProductCategory;

import java.math.BigDecimal;
import java.util.UUID;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ProductResponse {
    UUID id;
    UUID venueId;
    String name;
    String description;
    ProductCategory category;
    BigDecimal price;
    String unit;
    int stock;
    boolean active;
}
