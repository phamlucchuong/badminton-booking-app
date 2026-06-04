package vn.chuongpl.badbook.features.admin;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.stereotype.Service;
import vn.chuongpl.badbook.common.enums.BookingStatus;
import vn.chuongpl.badbook.common.enums.PlatformFeeStatus;
import vn.chuongpl.badbook.common.enums.VenueStatus;
import vn.chuongpl.badbook.features.admin.dto.SystemStatsResponse;
import vn.chuongpl.badbook.features.booking.BookingRepository;
import vn.chuongpl.badbook.features.finance.Finance;
import vn.chuongpl.badbook.features.finance.FinanceRepository;
import vn.chuongpl.badbook.features.finance.FinanceService;
import vn.chuongpl.badbook.features.finance.InvoiceRepository;
import vn.chuongpl.badbook.features.finance.PlatformFeeInvoice;
import vn.chuongpl.badbook.features.user.UserRepository;
import vn.chuongpl.badbook.features.venue.VenueRepository;

import java.math.BigDecimal;
import java.util.List;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class AdminService {

    UserRepository userRepository;
    VenueRepository venueRepository;
    BookingRepository bookingRepository;
    FinanceRepository financeRepository;
    InvoiceRepository invoiceRepository;
    FinanceService financeService;

    public SystemStatsResponse getSystemStats() {
        BigDecimal totalRevenue = financeRepository.findAll().stream()
                .map(Finance::getPlatformFeeAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        return SystemStatsResponse.builder()
                .totalUsers(userRepository.count())
                .totalVenues(venueRepository.count())
                .activeVenues(venueRepository.findByStatus(VenueStatus.ACTIVE,
                        org.springframework.data.domain.Pageable.unpaged()).getTotalElements())
                .pendingVenues(venueRepository.findByStatus(VenueStatus.PENDING,
                        org.springframework.data.domain.Pageable.unpaged()).getTotalElements())
                .totalBookings(bookingRepository.count())
                .completedBookings(bookingRepository.findAll().stream()
                        .filter(b -> b.getStatus() == BookingStatus.COMPLETED).count())
                .totalPlatformRevenue(totalRevenue)
                .pendingInvoices(invoiceRepository.findByStatus(PlatformFeeStatus.PENDING).size())
                .build();
    }

    public List<PlatformFeeInvoice> getPendingInvoices() {
        return financeService.getPendingInvoices();
    }

    public PlatformFeeInvoice generateInvoice(String venueId, String period) {
        return financeService.generateMonthlyInvoice(venueId, period);
    }

    public PlatformFeeInvoice markInvoicePaid(String invoiceId) {
        return financeService.markInvoicePaid(invoiceId);
    }
}
