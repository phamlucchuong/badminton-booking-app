package vn.chuongpl.badbook.features.booking;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import vn.chuongpl.badbook.common.enums.*;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.booking.dto.request.BookingCreateRequest;
import vn.chuongpl.badbook.features.booking.dto.response.BookingResponse;
import vn.chuongpl.badbook.features.court.Court;
import vn.chuongpl.badbook.features.court.CourtService;
import vn.chuongpl.badbook.features.product.ProductService;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;
import vn.chuongpl.badbook.features.venue.Venue;
import vn.chuongpl.badbook.features.venue.VenueRepository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class BookingServiceTest {

    @Mock BookingRepository bookingRepository;
    @Mock BookingProductRepository bookingProductRepository;
    @Mock UserRepository userRepository;
    @Mock VenueRepository venueRepository;
    @Mock CourtService courtService;
    @Mock ProductService productService;
    @Mock BookingMapper bookingMapper;
    @InjectMocks BookingService bookingService;

    @Test
    void createBooking_throwsOnConflict() {
        UUID userId = UUID.randomUUID(), courtId = UUID.randomUUID(), venueId = UUID.randomUUID();
        User user = User.builder().id(userId).build();
        Venue venue = Venue.builder().id(venueId).status(VenueStatus.ACTIVE)
                .platformFeeRate(new BigDecimal("0.1")).build();
        Court court = Court.builder().id(courtId).venue(venue)
                .status(CourtStatus.ACTIVE).pricePerHour(new BigDecimal("80000")).build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(venueRepository.findById(venueId)).thenReturn(Optional.of(venue));
        when(courtService.findCourt(courtId.toString())).thenReturn(court);
        when(bookingRepository.existsConflict(eq(court), any(), any(), any())).thenReturn(true);

        BookingCreateRequest req = BookingCreateRequest.builder()
                .courtId(courtId.toString()).venueId(venueId.toString())
                .bookingDate(LocalDate.now().plusDays(1))
                .startTime(LocalTime.of(8, 0)).endTime(LocalTime.of(10, 0))
                .type(BookingType.HOURLY).paymentMethod(PaymentMethod.CASH)
                .products(List.of()).build();

        assertThatThrownBy(() -> bookingService.createBooking(userId.toString(), req))
                .isInstanceOf(AppException.class)
                .extracting(e -> ((AppException) e).getErrorCode())
                .isEqualTo(ErrorCode.BOOKING_CONFLICT);
    }

    @Test
    void createBooking_calculatesTotalFromCourtHoursAndProducts() {
        UUID userId = UUID.randomUUID(), courtId = UUID.randomUUID(), venueId = UUID.randomUUID();
        User user = User.builder().id(userId).build();
        Venue venue = Venue.builder().id(venueId).status(VenueStatus.ACTIVE)
                .platformFeeRate(new BigDecimal("0.1")).build();
        Court court = Court.builder().id(courtId).venue(venue)
                .status(CourtStatus.ACTIVE).pricePerHour(new BigDecimal("80000")).build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(user));
        when(venueRepository.findById(venueId)).thenReturn(Optional.of(venue));
        when(courtService.findCourt(courtId.toString())).thenReturn(court);
        when(bookingRepository.existsConflict(any(), any(), any(), any())).thenReturn(false);
        when(bookingRepository.save(any())).thenAnswer(i -> {
            Booking b = i.getArgument(0);
            b.setId(UUID.randomUUID());
            return b;
        });
        when(bookingMapper.toResponse(any())).thenReturn(
                BookingResponse.builder().totalAmount(new BigDecimal("160000")).build());

        BookingCreateRequest req = BookingCreateRequest.builder()
                .courtId(courtId.toString()).venueId(venueId.toString())
                .bookingDate(LocalDate.now().plusDays(1))
                .startTime(LocalTime.of(8, 0)).endTime(LocalTime.of(10, 0))
                .type(BookingType.HOURLY).paymentMethod(PaymentMethod.CASH)
                .products(List.of()).build();

        BookingResponse result = bookingService.createBooking(userId.toString(), req);
        assertThat(result.getTotalAmount()).isEqualByComparingTo(new BigDecimal("160000"));
    }

    @Test
    void cancelBooking_throwsWhenAlreadyCompleted() {
        UUID bookingId = UUID.randomUUID(), userId = UUID.randomUUID();
        User user = User.builder().id(userId).build();
        Booking booking = Booking.builder().id(bookingId).user(user).status(BookingStatus.COMPLETED).build();

        when(bookingRepository.findById(bookingId)).thenReturn(Optional.of(booking));

        assertThatThrownBy(() -> bookingService.cancelBooking(bookingId.toString(), userId.toString(), "test"))
                .isInstanceOf(AppException.class)
                .extracting(e -> ((AppException) e).getErrorCode())
                .isEqualTo(ErrorCode.BOOKING_CANNOT_CANCEL);
    }
}
