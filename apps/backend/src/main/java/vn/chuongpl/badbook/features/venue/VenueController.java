package vn.chuongpl.badbook.features.venue;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.common.PageResponse;
import vn.chuongpl.badbook.features.venue.dto.request.VenueCreateRequest;
import vn.chuongpl.badbook.features.venue.dto.request.VenueOperatingHourRequest;
import vn.chuongpl.badbook.features.venue.dto.request.VenueUpdateRequest;
import vn.chuongpl.badbook.features.venue.dto.response.VenueAvailabilityResponse;
import vn.chuongpl.badbook.features.venue.dto.response.VenueOperatingHourResponse;
import vn.chuongpl.badbook.features.venue.dto.response.VenueResponse;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/venues")
@RequiredArgsConstructor
public class VenueController {

    private final VenueService venueService;

    @PostMapping
    @PreAuthorize("hasRole('VENUE_MANAGER')")
    public ApiResponse<VenueResponse> createVenue(@AuthenticationPrincipal Jwt jwt,
                                                  @RequestBody VenueCreateRequest request) {
        return ApiResponse.<VenueResponse>builder()
                .data(venueService.createVenue(jwt.getSubject(), request)).build();
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('VENUE_MANAGER')")
    public ApiResponse<VenueResponse> updateVenue(@PathVariable String id,
                                                  @RequestBody @Valid VenueUpdateRequest request,
                                                  @AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.<VenueResponse>builder()
                .data(venueService.updateVenue(id, jwt.getSubject(), request))
                .build();
    }

    @GetMapping("/my")
    @PreAuthorize("hasRole('VENUE_MANAGER')")
    public ApiResponse<VenueResponse> getMyVenue(@AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.<VenueResponse>builder()
                .data(venueService.getVenueByOwner(jwt.getSubject())).build();
    }

    @GetMapping
    public ApiResponse<PageResponse<VenueResponse>> getActiveVenues(
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ApiResponse.<PageResponse<VenueResponse>>builder()
                .data(venueService.getActiveVenues(keyword, page, size)).build();
    }

    @GetMapping("/{id}")
    public ApiResponse<VenueResponse> getVenue(@PathVariable String id) {
        return ApiResponse.<VenueResponse>builder()
                .data(venueService.getVenueById(id)).build();
    }

    @PutMapping("/{id}/approve")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<VenueResponse> approve(@PathVariable String id) {
        return ApiResponse.<VenueResponse>builder()
                .data(venueService.approveVenue(id)).build();
    }

    @PutMapping("/{id}/reject")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<VenueResponse> reject(@PathVariable String id) {
        return ApiResponse.<VenueResponse>builder()
                .data(venueService.rejectVenue(id)).build();
    }

    @PutMapping("/{id}/suspend")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<VenueResponse> suspend(@PathVariable String id) {
        return ApiResponse.<VenueResponse>builder()
                .data(venueService.suspendVenue(id)).build();
    }

    @GetMapping("/pending")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<PageResponse<VenueResponse>> getPending(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ApiResponse.<PageResponse<VenueResponse>>builder()
                .data(venueService.getPendingVenues(page, size)).build();
    }

    @GetMapping("/{venueId}/operating-hours")
    public ApiResponse<List<VenueOperatingHourResponse>> getOperatingHours(@PathVariable String venueId) {
        return ApiResponse.<List<VenueOperatingHourResponse>>builder()
                .data(venueService.getOperatingHours(venueId))
                .build();
    }

    @PutMapping("/{venueId}/operating-hours")
    @PreAuthorize("hasRole('VENUE_MANAGER')")
    public ApiResponse<List<VenueOperatingHourResponse>> updateOperatingHours(
            @PathVariable String venueId,
            @AuthenticationPrincipal Jwt jwt,
            @RequestBody List<VenueOperatingHourRequest> requests) {
        return ApiResponse.<List<VenueOperatingHourResponse>>builder()
                .data(venueService.updateOperatingHours(venueId, jwt.getSubject(), requests))
                .build();
    }

    @GetMapping("/{venueId}/availability")
    public ApiResponse<VenueAvailabilityResponse> getAvailability(
            @PathVariable String venueId,
            @RequestParam String date) {
        return ApiResponse.<VenueAvailabilityResponse>builder()
                .data(venueService.getAvailability(venueId, LocalDate.parse(date)))
                .build();
    }
}
