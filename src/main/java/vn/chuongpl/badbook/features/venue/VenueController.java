package vn.chuongpl.badbook.features.venue;

import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.common.PageResponse;
import vn.chuongpl.badbook.features.venue.dto.request.VenueCreateRequest;
import vn.chuongpl.badbook.features.venue.dto.response.VenueResponse;

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
}
