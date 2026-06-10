package vn.chuongpl.badbook.features.booking;

import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.common.PageResponse;
import vn.chuongpl.badbook.features.booking.dto.request.BookingCreateRequest;
import vn.chuongpl.badbook.features.booking.dto.response.BookingResponse;

@RestController
@RequestMapping("/api/bookings")
@RequiredArgsConstructor
public class BookingController {

    private final BookingService bookingService;

    @PostMapping
    @PreAuthorize("hasRole('USER')")
    public ApiResponse<BookingResponse> createBooking(@AuthenticationPrincipal Jwt jwt,
                                                       @RequestBody BookingCreateRequest request) {
        return ApiResponse.<BookingResponse>builder()
                .data(bookingService.createBooking(jwt.getSubject(), request)).build();
    }

    @PutMapping("/{id}/confirm")
    @PreAuthorize("hasRole('VENUE_MANAGER')")
    public ApiResponse<BookingResponse> confirmBooking(@AuthenticationPrincipal Jwt jwt,
                                                        @PathVariable String id) {
        return ApiResponse.<BookingResponse>builder()
                .data(bookingService.confirmBooking(id, jwt.getSubject())).build();
    }

    @PutMapping("/{id}/cancel")
    public ApiResponse<BookingResponse> cancelBooking(@AuthenticationPrincipal Jwt jwt,
                                                       @PathVariable String id,
                                                       @RequestParam(required = false) String reason) {
        return ApiResponse.<BookingResponse>builder()
                .data(bookingService.cancelBooking(id, jwt.getSubject(), reason)).build();
    }

    @PutMapping("/{id}/complete")
    @PreAuthorize("hasRole('VENUE_MANAGER') or hasRole('ADMIN')")
    public ApiResponse<BookingResponse> completeBooking(@PathVariable String id) {
        return ApiResponse.<BookingResponse>builder()
                .data(bookingService.completeBooking(id)).build();
    }

    @GetMapping("/my")
    @PreAuthorize("hasRole('USER')")
    public ApiResponse<PageResponse<BookingResponse>> getMyBookings(@AuthenticationPrincipal Jwt jwt,
                                                                     @RequestParam(defaultValue = "1") int page,
                                                                     @RequestParam(defaultValue = "10") int size) {
        return ApiResponse.<PageResponse<BookingResponse>>builder()
                .data(bookingService.getUserBookings(jwt.getSubject(), page, size)).build();
    }

    @GetMapping("/venue/{venueId}")
    @PreAuthorize("hasRole('VENUE_MANAGER') or hasRole('ADMIN')")
    public ApiResponse<PageResponse<BookingResponse>> getVenueBookings(@PathVariable String venueId,
                                                                        @RequestParam(defaultValue = "1") int page,
                                                                        @RequestParam(defaultValue = "10") int size) {
        return ApiResponse.<PageResponse<BookingResponse>>builder()
                .data(bookingService.getVenueBookings(venueId, page, size)).build();
    }
}
