package vn.chuongpl.badbook.features.review;

import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.common.PageResponse;
import vn.chuongpl.badbook.common.enums.ReviewTarget;
import vn.chuongpl.badbook.features.review.dto.ReviewCreateRequest;

@RestController
@RequestMapping("/api/reviews")
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewService reviewService;

    @PostMapping
    @PreAuthorize("hasRole('USER')")
    public ApiResponse<Review> createReview(@AuthenticationPrincipal Jwt jwt,
                                             @RequestBody ReviewCreateRequest request) {
        return ApiResponse.<Review>builder()
                .data(reviewService.createReview(jwt.getSubject(), request)).build();
    }

    @PutMapping("/{id}/reply")
    @PreAuthorize("hasRole('VENUE_MANAGER')")
    public ApiResponse<Review> reply(@AuthenticationPrincipal Jwt jwt,
                                      @PathVariable String id,
                                      @RequestParam String replyText) {
        return ApiResponse.<Review>builder()
                .data(reviewService.replyToReview(id, jwt.getSubject(), replyText)).build();
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<Void> deleteReview(@PathVariable String id) {
        reviewService.deleteReview(id);
        return ApiResponse.<Void>builder().message("Đã xóa đánh giá").build();
    }

    @GetMapping
    public ApiResponse<PageResponse<Review>> getReviews(
            @RequestParam ReviewTarget targetType,
            @RequestParam String targetId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ApiResponse.<PageResponse<Review>>builder()
                .data(reviewService.getReviews(targetType, targetId, page, size)).build();
    }
}
