package vn.chuongpl.badbook.features.review.dto;

import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.ReviewTarget;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ReviewCreateRequest {
    String bookingId;
    ReviewTarget targetType;
    String targetId;
    int rating;
    String content;
}
