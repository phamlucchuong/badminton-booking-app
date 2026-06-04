package vn.chuongpl.badbook.features.court;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import vn.chuongpl.badbook.common.enums.CourtStatus;
import vn.chuongpl.badbook.common.enums.CourtType;
import vn.chuongpl.badbook.common.enums.VenueStatus;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.court.dto.request.CourtCreateRequest;
import vn.chuongpl.badbook.features.court.dto.response.CourtResponse;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;
import vn.chuongpl.badbook.features.venue.Venue;
import vn.chuongpl.badbook.features.venue.VenueRepository;

import java.math.BigDecimal;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class CourtServiceTest {

    @Mock CourtRepository courtRepository;
    @Mock VenueRepository venueRepository;
    @Mock UserRepository userRepository;
    @Mock CourtMapper courtMapper;
    @InjectMocks CourtService courtService;

    @Test
    void createCourt_successForActiveVenueOwner() {
        UUID userId = UUID.randomUUID();
        UUID venueId = UUID.randomUUID();
        User owner = User.builder().id(userId).build();
        Venue venue = Venue.builder().id(venueId).owner(owner).status(VenueStatus.ACTIVE).build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(owner));
        when(venueRepository.findById(venueId)).thenReturn(Optional.of(venue));
        Court saved = Court.builder().id(UUID.randomUUID()).venue(venue).build();
        when(courtRepository.save(any())).thenReturn(saved);
        when(courtMapper.toResponse(any())).thenReturn(CourtResponse.builder().courtType(CourtType.STANDARD).build());

        CourtCreateRequest req = CourtCreateRequest.builder()
                .name("Sân A1").courtType(CourtType.STANDARD).pricePerHour(new BigDecimal("80000")).build();

        CourtResponse result = courtService.createCourt(userId.toString(), venueId.toString(), req);
        assertThat(result.getCourtType()).isEqualTo(CourtType.STANDARD);
    }

    @Test
    void createCourt_throwsWhenVenueNotOwnedByUser() {
        UUID userId = UUID.randomUUID();
        UUID venueId = UUID.randomUUID();
        User owner = User.builder().id(UUID.randomUUID()).build(); // different user
        Venue venue = Venue.builder().id(venueId).owner(owner).status(VenueStatus.ACTIVE).build();

        when(userRepository.findById(userId)).thenReturn(Optional.of(User.builder().id(userId).build()));
        when(venueRepository.findById(venueId)).thenReturn(Optional.of(venue));

        assertThatThrownBy(() -> courtService.createCourt(userId.toString(), venueId.toString(), new CourtCreateRequest()))
                .isInstanceOf(AppException.class);
    }
}
