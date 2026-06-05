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
import vn.chuongpl.badbook.features.venue.dto.response.CourtSlotResponse;
import vn.chuongpl.badbook.features.venue.dto.response.SlotResponse;
import vn.chuongpl.badbook.features.venue.dto.response.VenueAvailabilityResponse;
import vn.chuongpl.badbook.features.venue.dto.response.VenueOperatingHourResponse;
import vn.chuongpl.badbook.features.venue.dto.response.VenueResponse;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class VenueService {

    VenueRepository venueRepository;
    UserRepository userRepository;
    VenueMapper venueMapper;
    VenueOperatingHourRepository operatingHourRepository;
    CourtRepository courtRepository;
    BookingRepository bookingRepository;

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

    public List<VenueOperatingHourResponse> getOperatingHours(String venueId) {
        Venue venue = findVenue(venueId);
        return operatingHourRepository.findByVenue(venue).stream()
                .sorted(Comparator.comparingInt(hour -> hour.getDayOfWeek().getValue()))
                .map(this::toOperatingHourResponse)
                .toList();
    }

    @Transactional
    public List<VenueOperatingHourResponse> updateOperatingHours(String venueId,
                                                                 String ownerId,
                                                                 List<VenueOperatingHourRequest> requests) {
        Venue venue = findVenue(venueId);
        if (!venue.getOwner().getId().toString().equals(ownerId)) {
            throw new AppException(ErrorCode.VENUE_NOT_OWNED_BY_USER);
        }

        for (VenueOperatingHourRequest request : requests) {
            VenueOperatingHour operatingHour = operatingHourRepository
                    .findByVenueAndDayOfWeek(venue, request.getDayOfWeek())
                    .orElse(VenueOperatingHour.builder()
                            .venue(venue)
                            .dayOfWeek(request.getDayOfWeek())
                            .build());
            operatingHour.setClosed(request.isClosed());
            operatingHour.setOpenTime(request.isClosed() ? null : request.getOpenTime());
            operatingHour.setCloseTime(request.isClosed() ? null : request.getCloseTime());
            operatingHourRepository.save(operatingHour);
        }

        return getOperatingHours(venueId);
    }

    public VenueAvailabilityResponse getAvailability(String venueId, LocalDate date) {
        Venue venue = findVenue(venueId);
        Optional<VenueOperatingHour> operatingHour = operatingHourRepository
                .findByVenueAndDayOfWeek(venue, date.getDayOfWeek());

        if (operatingHour.isEmpty() || operatingHour.get().isClosed()
                || operatingHour.get().getOpenTime() == null || operatingHour.get().getCloseTime() == null) {
            return VenueAvailabilityResponse.builder()
                    .date(date)
                    .courts(List.of())
                    .build();
        }

        VenueOperatingHour hours = operatingHour.get();
        List<Court> courts = courtRepository.findByVenueAndStatus(venue, CourtStatus.ACTIVE);
        List<CourtSlotResponse> courtSlots = courts.stream()
                .map(court -> CourtSlotResponse.builder()
                        .courtId(court.getId().toString())
                        .courtName(court.getName())
                        .slots(buildSlots(hours.getOpenTime(), hours.getCloseTime(),
                                bookingRepository.findActiveBookingsForCourtOnDate(court, date)))
                        .build())
                .toList();

        return VenueAvailabilityResponse.builder()
                .date(date)
                .openTime(hours.getOpenTime())
                .closeTime(hours.getCloseTime())
                .courts(courtSlots)
                .build();
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

    private List<SlotResponse> buildSlots(LocalTime openTime, LocalTime closeTime, List<Booking> bookings) {
        List<SlotResponse> slots = new ArrayList<>();
        LocalTime current = openTime;
        while (current.isBefore(closeTime)) {
            LocalTime next = current.plusMinutes(30);
            LocalTime slotEnd = next.isAfter(closeTime) ? closeTime : next;
            LocalTime slotStart = current;
            boolean occupied = bookings.stream().anyMatch(booking ->
                    booking.getStartTime().isBefore(slotEnd) && booking.getEndTime().isAfter(slotStart));
            slots.add(SlotResponse.builder()
                    .startTime(slotStart)
                    .endTime(slotEnd)
                    .available(!occupied)
                    .build());
            current = slotEnd;
        }
        return slots;
    }

    private VenueOperatingHourResponse toOperatingHourResponse(VenueOperatingHour operatingHour) {
        return VenueOperatingHourResponse.builder()
                .dayOfWeek(operatingHour.getDayOfWeek())
                .openTime(operatingHour.getOpenTime())
                .closeTime(operatingHour.getCloseTime())
                .closed(operatingHour.isClosed())
                .build();
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
