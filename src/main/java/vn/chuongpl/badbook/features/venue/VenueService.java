package vn.chuongpl.badbook.features.venue;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.chuongpl.badbook.common.PageResponse;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.enums.VenueStatus;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;
import vn.chuongpl.badbook.features.venue.dto.request.VenueCreateRequest;
import vn.chuongpl.badbook.features.venue.dto.response.VenueResponse;

import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class VenueService {

    VenueRepository venueRepository;
    UserRepository userRepository;
    VenueMapper venueMapper;

    @Transactional
    public VenueResponse createVenue(String userId, VenueCreateRequest request) {
        User owner = findUser(userId);
        if (venueRepository.existsByOwner(owner)) throw new AppException(ErrorCode.VENUE_ALREADY_EXISTS);
        Venue venue = Venue.builder()
                .owner(owner)
                .name(request.getName())
                .address(request.getAddress())
                .latitude(request.getLatitude())
                .longitude(request.getLongitude())
                .description(request.getDescription())
                .licenseId(request.getLicenseId())
                .openTime(request.getOpenTime())
                .closeTime(request.getCloseTime())
                .bankName(request.getBankName())
                .bankNumber(request.getBankNumber())
                .bankAccountName(request.getBankAccountName())
                .status(VenueStatus.PENDING)
                .build();
        return venueMapper.toResponse(venueRepository.save(venue));
    }

    public VenueResponse getVenueByOwner(String userId) {
        User owner = findUser(userId);
        Venue venue = venueRepository.findByOwner(owner)
                .orElseThrow(() -> new AppException(ErrorCode.VENUE_NOT_FOUND));
        return venueMapper.toResponse(venue);
    }

    public VenueResponse getVenueById(String venueId) {
        return venueMapper.toResponse(findVenue(venueId));
    }

    public PageResponse<VenueResponse> getActiveVenues(String keyword, int page, int size) {
        PageRequest pageable = PageRequest.of(page - 1, size, Sort.by("createdAt").descending());
        Page<Venue> result = (keyword != null && !keyword.isBlank())
                ? venueRepository.findByNameContainingIgnoreCaseAndStatus(keyword, VenueStatus.ACTIVE, pageable)
                : venueRepository.findByStatus(VenueStatus.ACTIVE, pageable);
        return buildPageResponse(result, page, size);
    }

    public PageResponse<VenueResponse> getPendingVenues(int page, int size) {
        Page<Venue> result = venueRepository.findByStatus(VenueStatus.PENDING,
                PageRequest.of(page - 1, size, Sort.by("createdAt").ascending()));
        return buildPageResponse(result, page, size);
    }

    @Transactional
    public VenueResponse approveVenue(String venueId) {
        return changeStatus(venueId, VenueStatus.ACTIVE);
    }

    @Transactional
    public VenueResponse rejectVenue(String venueId) {
        return changeStatus(venueId, VenueStatus.REJECTED);
    }

    @Transactional
    public VenueResponse suspendVenue(String venueId) {
        return changeStatus(venueId, VenueStatus.SUSPENDED);
    }

    @Transactional
    public VenueResponse updateBannerIds(String venueId, String ownerId, String bannerIds) {
        Venue venue = findVenue(venueId);
        User owner = findUser(ownerId);
        if (!venue.getOwner().getId().equals(owner.getId())) throw new AppException(ErrorCode.VENUE_NOT_OWNED_BY_USER);
        venue.setBannerIds(bannerIds);
        return venueMapper.toResponse(venueRepository.save(venue));
    }

    private VenueResponse changeStatus(String venueId, VenueStatus status) {
        Venue venue = findVenue(venueId);
        venue.setStatus(status);
        return venueMapper.toResponse(venueRepository.save(venue));
    }

    private Venue findVenue(String venueId) {
        try {
            return venueRepository.findById(UUID.fromString(venueId))
                    .orElseThrow(() -> new AppException(ErrorCode.VENUE_NOT_FOUND));
        } catch (IllegalArgumentException e) {
            throw new AppException(ErrorCode.ID_INVALID);
        }
    }

    private User findUser(String userId) {
        try {
            return userRepository.findById(UUID.fromString(userId))
                    .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
        } catch (IllegalArgumentException e) {
            throw new AppException(ErrorCode.ID_INVALID);
        }
    }

    private PageResponse<VenueResponse> buildPageResponse(Page<Venue> page, int pageNum, int size) {
        return PageResponse.<VenueResponse>builder()
                .items(page.getContent().stream().map(venueMapper::toResponse).toList())
                .total(page.getTotalElements())
                .page(pageNum)
                .pageSize(size)
                .totalPages(page.getTotalPages())
                .build();
    }
}
