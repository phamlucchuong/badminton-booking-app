package vn.chuongpl.badbook.features.review;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import vn.chuongpl.badbook.common.enums.BookingStatus;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.enums.ReviewTarget;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.booking.Booking;
import vn.chuongpl.badbook.features.booking.BookingRepository;
import vn.chuongpl.badbook.features.review.dto.ReviewCreateRequest;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ReviewServiceTest {

    @Mock ReviewRepository reviewRepository;
    @Mock BookingRepository bookingRepository;
    @Mock UserRepository userRepository;
    @InjectMocks ReviewService reviewService;

    @Test
    void createReview_throwsWhenBookingNotCompleted() {
        UUID userId = UUID.randomUUID(), bookingId = UUID.randomUUID();
        User user = User.builder().id(userId).build();
        Booking booking = Booking.builder().id(bookingId).user(user).status(BookingStatus.CONFIRMED).build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(bookingRepository.findById(bookingId)).thenReturn(Optional.of(booking));

        ReviewCreateRequest req = ReviewCreateRequest.builder()
                .bookingId(bookingId.toString()).targetType(ReviewTarget.VENUE)
                .targetId(UUID.randomUUID().toString()).rating(5).content("Tốt").build();

        assertThatThrownBy(() -> reviewService.createReview(userId.toString(), req))
                .isInstanceOf(AppException.class)
                .extracting(e -> ((AppException) e).getErrorCode())
                .isEqualTo(ErrorCode.REVIEW_ONLY_AFTER_COMPLETION);
    }

    @Test
    void createReview_throwsWhenAlreadyReviewed() {
        UUID userId = UUID.randomUUID(), bookingId = UUID.randomUUID();
        User user = User.builder().id(userId).build();
        Booking booking = Booking.builder().id(bookingId).user(user).status(BookingStatus.COMPLETED).build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(bookingRepository.findById(bookingId)).thenReturn(Optional.of(booking));
        when(reviewRepository.existsByUserAndBookingAndTargetType(any(), any(), any())).thenReturn(true);

        ReviewCreateRequest req = ReviewCreateRequest.builder()
                .bookingId(bookingId.toString()).targetType(ReviewTarget.VENUE)
                .targetId(UUID.randomUUID().toString()).rating(5).content("Tốt").build();

        assertThatThrownBy(() -> reviewService.createReview(userId.toString(), req))
                .isInstanceOf(AppException.class)
                .extracting(e -> ((AppException) e).getErrorCode())
                .isEqualTo(ErrorCode.REVIEW_ALREADY_SUBMITTED);
    }

    @Test
    void createReview_successAfterCompletedBooking() {
        UUID userId = UUID.randomUUID(), bookingId = UUID.randomUUID(), targetId = UUID.randomUUID();
        User user = User.builder().id(userId).build();
        Booking booking = Booking.builder().id(bookingId).user(user).status(BookingStatus.COMPLETED).build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(bookingRepository.findById(bookingId)).thenReturn(Optional.of(booking));
        when(reviewRepository.existsByUserAndBookingAndTargetType(any(), any(), any())).thenReturn(false);
        when(reviewRepository.save(any())).thenAnswer(i -> {
            Review r = i.getArgument(0);
            r.setId(UUID.randomUUID());
            return r;
        });

        ReviewCreateRequest req = ReviewCreateRequest.builder()
                .bookingId(bookingId.toString()).targetType(ReviewTarget.VENUE)
                .targetId(targetId.toString()).rating(5).content("Rất tốt!").build();

        Review result = reviewService.createReview(userId.toString(), req);
        assertThat(result.getRating()).isEqualTo(5);
        assertThat(result.getContent()).isEqualTo("Rất tốt!");
    }
}
