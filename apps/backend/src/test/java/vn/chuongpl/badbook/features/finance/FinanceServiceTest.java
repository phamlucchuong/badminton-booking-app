package vn.chuongpl.badbook.features.finance;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import vn.chuongpl.badbook.features.booking.Booking;
import vn.chuongpl.badbook.features.venue.Venue;

import java.math.BigDecimal;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class FinanceServiceTest {

    @Mock FinanceRepository financeRepository;
    @Mock InvoiceRepository invoiceRepository;
    @Mock vn.chuongpl.badbook.features.venue.VenueRepository venueRepository;
    @InjectMocks FinanceService financeService;

    @Test
    void createFinanceRecord_splitsPlatformFeeCorrectly() {
        Venue venue = Venue.builder().id(UUID.randomUUID())
                .platformFeeRate(new BigDecimal("0.10")).build();
        Booking booking = Booking.builder().id(UUID.randomUUID())
                .venue(venue).totalAmount(new BigDecimal("200000")).build();

        when(financeRepository.findByBookingId(booking.getId())).thenReturn(Optional.empty());
        when(financeRepository.save(any())).thenAnswer(i -> i.getArgument(0));

        Finance result = financeService.createFinanceRecord(booking);

        assertThat(result.getPlatformFeeAmount()).isEqualByComparingTo(new BigDecimal("20000.00"));
        assertThat(result.getVenueRevenue()).isEqualByComparingTo(new BigDecimal("180000.00"));
        assertThat(result.getTotalAmount()).isEqualByComparingTo(new BigDecimal("200000"));
    }
}
