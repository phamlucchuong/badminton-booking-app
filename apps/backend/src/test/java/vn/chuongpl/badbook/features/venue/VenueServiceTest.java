package vn.chuongpl.badbook.features.venue;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import vn.chuongpl.badbook.common.enums.CourtStatus;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.enums.VenueStatus;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.booking.Booking;
import vn.chuongpl.badbook.features.booking.BookingRepository;
import vn.chuongpl.badbook.features.court.Court;
import vn.chuongpl.badbook.features.court.CourtRepository;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;
import vn.chuongpl.badbook.features.venue.dto.request.VenueCreateRequest;
import vn.chuongpl.badbook.features.venue.dto.request.VenueOperatingHourRequest;
import vn.chuongpl.badbook.features.venue.dto.response.SlotResponse;
import vn.chuongpl.badbook.features.venue.dto.response.VenueAvailabilityResponse;
import vn.chuongpl.badbook.features.venue.dto.response.VenueOperatingHourResponse;
import vn.chuongpl.badbook.features.venue.dto.response.VenueResponse;

import java.math.BigDecimal;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class VenueServiceTest {

    @Mock VenueRepository venueRepository;
    @Mock UserRepository userRepository;
    @Mock VenueMapper venueMapper;
    @Mock VenueOperatingHourRepository operatingHourRepository;
    @Mock CourtRepository courtRepository;
    @Mock BookingRepository bookingRepository;
    @InjectMocks VenueService venueService;

    @Test
    void createVenue_successWhenUserHasNoVenue() {
        String userId = UUID.randomUUID().toString();
        User user = User.builder().id(UUID.fromString(userId)).name("Owner").build();
        when(userRepository.findById(any(UUID.class))).thenReturn(Optional.of(user));
        when(venueRepository.existsByOwner(user)).thenReturn(false);
        Venue saved = Venue.builder().id(UUID.randomUUID()).owner(user).status(VenueStatus.PENDING).build();
        when(venueRepository.save(any())).thenReturn(saved);
        when(venueMapper.toResponse(any())).thenReturn(VenueResponse.builder().status(VenueStatus.PENDING).build());

        VenueCreateRequest request = VenueCreateRequest.builder()
                .name("Sân cầu ABC").address("123 Đường ABC")
                .latitude(new BigDecimal("10.7769")).longitude(new BigDecimal("106.7009"))
                .licenseId("LIC001").openTime(LocalTime.of(6, 0)).closeTime(LocalTime.of(22, 0))
                .build();

        VenueResponse result = venueService.createVenue(userId, request);
        assertThat(result.getStatus()).isEqualTo(VenueStatus.PENDING);
    }

    @Test
    void createVenue_throwsWhenUserAlreadyHasVenue() {
        String userId = UUID.randomUUID().toString();
        User user = User.builder().id(UUID.fromString(userId)).build();
        when(userRepository.findById(any(UUID.class))).thenReturn(Optional.of(user));
        when(venueRepository.existsByOwner(user)).thenReturn(true);

        assertThatThrownBy(() -> venueService.createVenue(userId, new VenueCreateRequest()))
                .isInstanceOf(AppException.class);
    }

    @Test
    void approveVenue_changesStatusToActive() {
        UUID venueId = UUID.randomUUID();
        Venue venue = Venue.builder().id(venueId).status(VenueStatus.PENDING).build();
        when(venueRepository.findById(venueId)).thenReturn(Optional.of(venue));
        when(venueRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));
        when(venueMapper.toResponse(any())).thenReturn(VenueResponse.builder().status(VenueStatus.ACTIVE).build());

        VenueResponse result = venueService.approveVenue(venueId.toString());
        assertThat(result.getStatus()).isEqualTo(VenueStatus.ACTIVE);
    }

    @Test
    void getOperatingHours_returnsListForVenue() {
        UUID venueId = UUID.randomUUID();
        Venue venue = Venue.builder().id(venueId).build();
        VenueOperatingHour monday = VenueOperatingHour.builder()
                .dayOfWeek(DayOfWeek.MONDAY)
                .openTime(LocalTime.of(7, 0))
                .closeTime(LocalTime.of(22, 0))
                .closed(false)
                .build();

        when(venueRepository.findById(venueId)).thenReturn(Optional.of(venue));
        when(operatingHourRepository.findByVenue(venue)).thenReturn(List.of(monday));

        List<VenueOperatingHourResponse> result = venueService.getOperatingHours(venueId.toString());

        assertThat(result).hasSize(1);
        assertThat(result.get(0).getDayOfWeek()).isEqualTo(DayOfWeek.MONDAY);
        assertThat(result.get(0).getOpenTime()).isEqualTo(LocalTime.of(7, 0));
    }

    @Test
    void updateOperatingHours_upsertsSingleDay() {
        UUID venueId = UUID.randomUUID();
        UUID ownerId = UUID.randomUUID();
        User owner = User.builder().id(ownerId).build();
        Venue venue = Venue.builder().id(venueId).owner(owner).build();

        VenueOperatingHourRequest request = VenueOperatingHourRequest.builder()
                .dayOfWeek(DayOfWeek.TUESDAY)
                .openTime(LocalTime.of(8, 0))
                .closeTime(LocalTime.of(21, 0))
                .closed(false)
                .build();

        when(venueRepository.findById(venueId)).thenReturn(Optional.of(venue));
        when(operatingHourRepository.findByVenueAndDayOfWeek(venue, DayOfWeek.TUESDAY))
                .thenReturn(Optional.empty());
        when(operatingHourRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));
        when(operatingHourRepository.findByVenue(venue)).thenReturn(List.of(
                VenueOperatingHour.builder()
                        .venue(venue)
                        .dayOfWeek(DayOfWeek.TUESDAY)
                        .openTime(LocalTime.of(8, 0))
                        .closeTime(LocalTime.of(21, 0))
                        .closed(false)
                        .build()
        ));

        List<VenueOperatingHourResponse> result = venueService.updateOperatingHours(
                venueId.toString(), ownerId.toString(), List.of(request));

        verify(operatingHourRepository).save(any(VenueOperatingHour.class));
        assertThat(result).hasSize(1);
    }

    @Test
    void updateOperatingHours_throwsUnauthorized_whenNotOwner() {
        UUID venueId = UUID.randomUUID();
        User owner = User.builder().id(UUID.randomUUID()).build();
        Venue venue = Venue.builder().id(venueId).owner(owner).build();

        when(venueRepository.findById(venueId)).thenReturn(Optional.of(venue));

        assertThatThrownBy(() -> venueService.updateOperatingHours(
                venueId.toString(), UUID.randomUUID().toString(), List.of()))
                .isInstanceOf(AppException.class)
                .extracting("errorCode").isEqualTo(ErrorCode.VENUE_NOT_OWNED_BY_USER);
    }

    @Test
    void getAvailability_marksSlotOccupied_whenBookingOverlaps() {
        UUID venueId = UUID.randomUUID();
        LocalDate date = LocalDate.of(2026, 6, 10);
        Venue venue = Venue.builder().id(venueId).build();
        UUID courtId = UUID.randomUUID();
        Court court = Court.builder().id(courtId).name("Sân 1").status(CourtStatus.ACTIVE).build();

        VenueOperatingHour hours = VenueOperatingHour.builder()
                .dayOfWeek(DayOfWeek.WEDNESDAY)
                .openTime(LocalTime.of(7, 0))
                .closeTime(LocalTime.of(9, 0))
                .closed(false)
                .build();

        Booking booking = Booking.builder()
                .court(court)
                .startTime(LocalTime.of(7, 0))
                .endTime(LocalTime.of(8, 0))
                .build();

        when(venueRepository.findById(venueId)).thenReturn(Optional.of(venue));
        when(operatingHourRepository.findByVenueAndDayOfWeek(venue, DayOfWeek.WEDNESDAY))
                .thenReturn(Optional.of(hours));
        when(courtRepository.findByVenueAndStatus(venue, CourtStatus.ACTIVE))
                .thenReturn(List.of(court));
        when(bookingRepository.findActiveBookingsForCourtOnDate(court, date))
                .thenReturn(List.of(booking));

        VenueAvailabilityResponse response = venueService.getAvailability(venueId.toString(), date);

        assertThat(response.getCourts()).hasSize(1);
        List<SlotResponse> slots = response.getCourts().get(0).getSlots();
        assertThat(slots).hasSize(4);
        assertThat(slots.get(0).isAvailable()).isFalse();
        assertThat(slots.get(1).isAvailable()).isFalse();
        assertThat(slots.get(2).isAvailable()).isTrue();
        assertThat(slots.get(3).isAvailable()).isTrue();
    }

    @Test
    void getAvailability_returnsEmptyCourts_whenVenueClosedOnDay() {
        UUID venueId = UUID.randomUUID();
        LocalDate date = LocalDate.of(2026, 6, 14);
        Venue venue = Venue.builder().id(venueId).build();

        VenueOperatingHour hours = VenueOperatingHour.builder()
                .dayOfWeek(DayOfWeek.SUNDAY)
                .closed(true)
                .build();

        when(venueRepository.findById(venueId)).thenReturn(Optional.of(venue));
        when(operatingHourRepository.findByVenueAndDayOfWeek(venue, DayOfWeek.SUNDAY))
                .thenReturn(Optional.of(hours));

        VenueAvailabilityResponse response = venueService.getAvailability(venueId.toString(), date);

        assertThat(response.getCourts()).isEmpty();
    }

    @Test
    void getAvailability_returnsEmptyCourts_whenNoOperatingHoursConfigured() {
        UUID venueId = UUID.randomUUID();
        LocalDate date = LocalDate.of(2026, 6, 10);
        Venue venue = Venue.builder().id(venueId).build();

        when(venueRepository.findById(venueId)).thenReturn(Optional.of(venue));
        when(operatingHourRepository.findByVenueAndDayOfWeek(venue, DayOfWeek.WEDNESDAY))
                .thenReturn(Optional.empty());

        VenueAvailabilityResponse response = venueService.getAvailability(venueId.toString(), date);

        assertThat(response.getCourts()).isEmpty();
    }
}
