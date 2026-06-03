package vn.chuongpl.badbook.features.venue;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import vn.chuongpl.badbook.common.enums.VenueStatus;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;
import vn.chuongpl.badbook.features.venue.dto.request.VenueCreateRequest;
import vn.chuongpl.badbook.features.venue.dto.response.VenueResponse;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class VenueServiceTest {

    @Mock VenueRepository venueRepository;
    @Mock UserRepository userRepository;
    @Mock VenueMapper venueMapper;
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

        VenueCreateRequest req = VenueCreateRequest.builder()
                .name("Sân cầu ABC").address("123 Đường ABC")
                .latitude(new BigDecimal("10.7769")).longitude(new BigDecimal("106.7009"))
                .licenseId("LIC001").openTime(LocalTime.of(6, 0)).closeTime(LocalTime.of(22, 0))
                .build();

        VenueResponse result = venueService.createVenue(userId, req);
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
        when(venueRepository.save(any())).thenAnswer(i -> i.getArgument(0));
        when(venueMapper.toResponse(any())).thenReturn(VenueResponse.builder().status(VenueStatus.ACTIVE).build());

        VenueResponse result = venueService.approveVenue(venueId.toString());
        assertThat(result.getStatus()).isEqualTo(VenueStatus.ACTIVE);
    }
}
