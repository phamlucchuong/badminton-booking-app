package vn.chuongpl.badbook.features.finance;

import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;
import vn.chuongpl.badbook.features.venue.Venue;
import vn.chuongpl.badbook.features.venue.VenueRepository;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/finance")
@RequiredArgsConstructor
public class FinanceController {

    private final FinanceService financeService;
    private final VenueRepository venueRepository;
    private final UserRepository userRepository;

    @GetMapping("/my-invoices")
    @PreAuthorize("hasRole('VENUE_MANAGER')")
    public ApiResponse<List<PlatformFeeInvoice>> getMyInvoices(@AuthenticationPrincipal Jwt jwt) {
        User user = userRepository.findById(UUID.fromString(jwt.getSubject()))
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
        Venue venue = venueRepository.findByOwner(user)
                .orElseThrow(() -> new AppException(ErrorCode.VENUE_NOT_FOUND));
        return ApiResponse.<List<PlatformFeeInvoice>>builder()
                .data(financeService.getVenueInvoices(venue.getId().toString()))
                .build();
    }
}
