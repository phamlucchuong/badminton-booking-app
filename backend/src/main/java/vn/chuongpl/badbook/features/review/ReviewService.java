package vn.chuongpl.badbook.features.review;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.chuongpl.badbook.common.PageResponse;
import vn.chuongpl.badbook.common.enums.BookingStatus;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.enums.ReviewTarget;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.booking.Booking;
import vn.chuongpl.badbook.features.booking.BookingRepository;
import vn.chuongpl.badbook.features.review.dto.ReviewCreateRequest;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class ReviewService {

    ReviewRepository reviewRepository;
    BookingRepository bookingRepository;
    UserRepository userRepository;

    @Transactional
    public Review createReview(String userId, ReviewCreateRequest request) {
        User user = userRepository.findById(UUID.fromString(userId))
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
        Booking booking = bookingRepository.findById(UUID.fromString(request.getBookingId()))
                .orElseThrow(() -> new AppException(ErrorCode.BOOKING_NOT_FOUND));

        if (!booking.getUser().getId().equals(user.getId()))
            throw new AppException(ErrorCode.UNAUTHORIZED);
        if (booking.getStatus() != BookingStatus.COMPLETED)
            throw new AppException(ErrorCode.REVIEW_ONLY_AFTER_COMPLETION);
        if (reviewRepository.existsByUserAndBookingAndTargetType(user, booking, request.getTargetType()))
            throw new AppException(ErrorCode.REVIEW_ALREADY_SUBMITTED);

        return reviewRepository.save(Review.builder()
                .user(user).booking(booking)
                .targetType(request.getTargetType())
                .targetId(UUID.fromString(request.getTargetId()))
                .rating(request.getRating()).content(request.getContent()).build());
    }

    @Transactional
    public Review replyToReview(String reviewId, String venueManagerId, String replyText) {
        Review review = reviewRepository.findByIdAndDeletedFalse(UUID.fromString(reviewId))
                .orElseThrow(() -> new AppException(ErrorCode.REVIEW_NOT_FOUND));
        if (review.getReplyText() != null) throw new AppException(ErrorCode.REVIEW_ALREADY_REPLIED);
        review.setReplyText(replyText);
        review.setReplyAt(LocalDateTime.now());
        return reviewRepository.save(review);
    }

    @Transactional
    public void deleteReview(String reviewId) {
        Review review = reviewRepository.findByIdAndDeletedFalse(UUID.fromString(reviewId))
                .orElseThrow(() -> new AppException(ErrorCode.REVIEW_NOT_FOUND));
        review.setDeleted(true);
        reviewRepository.save(review);
    }

    public PageResponse<Review> getReviews(ReviewTarget targetType, String targetId, int page, int size) {
        Page<Review> result = reviewRepository.findByTargetTypeAndTargetIdAndDeletedFalse(
                targetType, UUID.fromString(targetId),
                PageRequest.of(page - 1, size, Sort.by("createdAt").descending()));
        return PageResponse.<Review>builder()
                .items(result.getContent()).total(result.getTotalElements())
                .page(page).pageSize(size).totalPages(result.getTotalPages()).build();
    }
}
