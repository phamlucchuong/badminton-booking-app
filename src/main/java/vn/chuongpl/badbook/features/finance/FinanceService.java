package vn.chuongpl.badbook.features.finance;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.enums.PlatformFeeStatus;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.booking.Booking;
import vn.chuongpl.badbook.features.venue.Venue;
import vn.chuongpl.badbook.features.venue.VenueRepository;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class FinanceService {

    FinanceRepository financeRepository;
    InvoiceRepository invoiceRepository;
    VenueRepository venueRepository;

    @Transactional
    public Finance createFinanceRecord(Booking booking) {
        if (financeRepository.findByBookingId(booking.getId()).isPresent()) {
            log.warn("Finance record already exists for booking {}", booking.getId());
            return financeRepository.findByBookingId(booking.getId()).get();
        }
        BigDecimal total = booking.getTotalAmount();
        BigDecimal feeRate = booking.getVenue().getPlatformFeeRate();
        BigDecimal platformFee = total.multiply(feeRate).setScale(2, RoundingMode.HALF_UP);
        BigDecimal venueRevenue = total.subtract(platformFee);

        return financeRepository.save(Finance.builder()
                .booking(booking).totalAmount(total)
                .platformFeeAmount(platformFee).venueRevenue(venueRevenue)
                .status("COMPLETED").build());
    }

    @Transactional
    public PlatformFeeInvoice generateMonthlyInvoice(String venueId, String period) {
        Venue venue = venueRepository.findById(UUID.fromString(venueId))
                .orElseThrow(() -> new AppException(ErrorCode.VENUE_NOT_FOUND));

        if (invoiceRepository.findByVenueAndPeriod(venue, period).isPresent()) {
            throw new AppException(ErrorCode.PLATFORM_FEE_ALREADY_PAID);
        }

        List<Finance> records = financeRepository.findByVenueAndPeriod(venue, period);
        BigDecimal totalRevenue = records.stream().map(Finance::getTotalAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal totalFee = records.stream().map(Finance::getPlatformFeeAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        YearMonth ym = YearMonth.parse(period);
        LocalDate dueDate = ym.plusMonths(1).atDay(15);

        return invoiceRepository.save(PlatformFeeInvoice.builder()
                .venue(venue).period(period)
                .totalBookings(records.size()).totalRevenue(totalRevenue)
                .feeAmount(totalFee).status(PlatformFeeStatus.PENDING).dueDate(dueDate).build());
    }

    @Transactional
    public PlatformFeeInvoice markInvoicePaid(String invoiceId) {
        PlatformFeeInvoice invoice = invoiceRepository.findById(UUID.fromString(invoiceId))
                .orElseThrow(() -> new AppException(ErrorCode.INVOICE_NOT_FOUND));
        if (invoice.getStatus() == PlatformFeeStatus.PAID)
            throw new AppException(ErrorCode.PLATFORM_FEE_ALREADY_PAID);
        invoice.setStatus(PlatformFeeStatus.PAID);
        invoice.setPaidAt(java.time.LocalDateTime.now());
        return invoiceRepository.save(invoice);
    }

    public List<PlatformFeeInvoice> getVenueInvoices(String venueId) {
        Venue venue = venueRepository.findById(UUID.fromString(venueId))
                .orElseThrow(() -> new AppException(ErrorCode.VENUE_NOT_FOUND));
        return invoiceRepository.findByVenue(venue);
    }

    public List<PlatformFeeInvoice> getPendingInvoices() {
        return invoiceRepository.findByStatus(PlatformFeeStatus.PENDING);
    }
}
