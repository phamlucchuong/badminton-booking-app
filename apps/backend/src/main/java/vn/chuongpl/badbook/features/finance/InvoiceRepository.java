package vn.chuongpl.badbook.features.finance;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.chuongpl.badbook.common.enums.PlatformFeeStatus;
import vn.chuongpl.badbook.features.venue.Venue;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface InvoiceRepository extends JpaRepository<PlatformFeeInvoice, UUID> {
    Optional<PlatformFeeInvoice> findByVenueAndPeriod(Venue venue, String period);
    List<PlatformFeeInvoice> findByStatus(PlatformFeeStatus status);
    List<PlatformFeeInvoice> findByVenue(Venue venue);
}
