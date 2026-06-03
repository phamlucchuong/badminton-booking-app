package vn.chuongpl.badbook.features.court;

import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.common.enums.CourtStatus;
import vn.chuongpl.badbook.features.court.dto.request.CourtCreateRequest;
import vn.chuongpl.badbook.features.court.dto.response.CourtResponse;

import java.util.List;

@RestController
@RequestMapping("/api/venues/{venueId}/courts")
@RequiredArgsConstructor
public class CourtController {

    private final CourtService courtService;

    @PostMapping
    @PreAuthorize("hasRole('VENUE_MANAGER')")
    public ApiResponse<CourtResponse> createCourt(@AuthenticationPrincipal Jwt jwt,
                                                    @PathVariable String venueId,
                                                    @RequestBody CourtCreateRequest request) {
        return ApiResponse.<CourtResponse>builder()
                .data(courtService.createCourt(jwt.getSubject(), venueId, request)).build();
    }

    @GetMapping
    public ApiResponse<List<CourtResponse>> getCourts(@PathVariable String venueId) {
        return ApiResponse.<List<CourtResponse>>builder()
                .data(courtService.getCourtsByVenue(venueId)).build();
    }

    @GetMapping("/{courtId}")
    public ApiResponse<CourtResponse> getCourt(@PathVariable String venueId,
                                                @PathVariable String courtId) {
        return ApiResponse.<CourtResponse>builder()
                .data(courtService.getCourtById(courtId)).build();
    }

    @PutMapping("/{courtId}/status")
    @PreAuthorize("hasRole('VENUE_MANAGER')")
    public ApiResponse<CourtResponse> setStatus(@AuthenticationPrincipal Jwt jwt,
                                                 @PathVariable String venueId,
                                                 @PathVariable String courtId,
                                                 @RequestParam CourtStatus status) {
        return ApiResponse.<CourtResponse>builder()
                .data(courtService.setStatus(jwt.getSubject(), venueId, courtId, status)).build();
    }
}
