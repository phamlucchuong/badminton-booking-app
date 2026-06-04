package vn.chuongpl.badbook.features.court;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.chuongpl.badbook.common.enums.CourtStatus;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.enums.VenueStatus;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.court.dto.request.CourtCreateRequest;
import vn.chuongpl.badbook.features.court.dto.response.CourtResponse;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;
import vn.chuongpl.badbook.features.venue.Venue;
import vn.chuongpl.badbook.features.venue.VenueRepository;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class CourtService {

    CourtRepository courtRepository;
    VenueRepository venueRepository;
    UserRepository userRepository;
    CourtMapper courtMapper;

    @Transactional
    public CourtResponse createCourt(String userId, String venueId, CourtCreateRequest request) {
        User user = findUser(userId);
        Venue venue = findVenue(venueId);
        assertOwner(venue, user);
        if (venue.getStatus() != VenueStatus.ACTIVE) throw new AppException(ErrorCode.VENUE_NOT_APPROVED);

        Court court = Court.builder()
                .venue(venue)
                .name(request.getName())
                .courtType(request.getCourtType())
                .pricePerHour(request.getPricePerHour())
                .description(request.getDescription())
                .status(CourtStatus.ACTIVE)
                .build();
        return courtMapper.toResponse(courtRepository.save(court));
    }

    public List<CourtResponse> getCourtsByVenue(String venueId) {
        Venue venue = findVenue(venueId);
        return courtRepository.findByVenueAndStatus(venue, CourtStatus.ACTIVE)
                .stream().map(courtMapper::toResponse).toList();
    }

    public CourtResponse getCourtById(String courtId) {
        return courtMapper.toResponse(findCourt(courtId));
    }

    @Transactional
    public CourtResponse setStatus(String userId, String venueId, String courtId, CourtStatus status) {
        User user = findUser(userId);
        Venue venue = findVenue(venueId);
        assertOwner(venue, user);
        Court court = courtRepository.findByIdAndVenue(UUID.fromString(courtId), venue)
                .orElseThrow(() -> new AppException(ErrorCode.COURT_NOT_IN_VENUE));
        court.setStatus(status);
        return courtMapper.toResponse(courtRepository.save(court));
    }

    @Transactional
    public CourtResponse updateImageIds(String userId, String venueId, String courtId, String imageIds) {
        User user = findUser(userId);
        Venue venue = findVenue(venueId);
        assertOwner(venue, user);
        Court court = courtRepository.findByIdAndVenue(UUID.fromString(courtId), venue)
                .orElseThrow(() -> new AppException(ErrorCode.COURT_NOT_IN_VENUE));
        court.setImageIds(imageIds);
        return courtMapper.toResponse(courtRepository.save(court));
    }

    private void assertOwner(Venue venue, User user) {
        if (!venue.getOwner().getId().equals(user.getId()))
            throw new AppException(ErrorCode.VENUE_NOT_OWNED_BY_USER);
    }

    public Court findCourt(String courtId) {
        try {
            return courtRepository.findById(UUID.fromString(courtId))
                    .orElseThrow(() -> new AppException(ErrorCode.COURT_NOT_FOUND));
        } catch (IllegalArgumentException e) { throw new AppException(ErrorCode.ID_INVALID); }
    }

    private Venue findVenue(String venueId) {
        try {
            return venueRepository.findById(UUID.fromString(venueId))
                    .orElseThrow(() -> new AppException(ErrorCode.VENUE_NOT_FOUND));
        } catch (IllegalArgumentException e) { throw new AppException(ErrorCode.ID_INVALID); }
    }

    private User findUser(String userId) {
        try {
            return userRepository.findById(UUID.fromString(userId))
                    .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
        } catch (IllegalArgumentException e) { throw new AppException(ErrorCode.ID_INVALID); }
    }
}
