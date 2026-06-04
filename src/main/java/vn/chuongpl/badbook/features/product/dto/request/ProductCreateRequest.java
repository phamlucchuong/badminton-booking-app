package vn.chuongpl.badbook.features.product.dto.request;

import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.ProductCategory;

import java.math.BigDecimal;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ProductCreateRequest {
    String name;
    String description;
    ProductCategory category;
    BigDecimal price;
    String unit;
    int stock;
}
