package vn.chuongpl.badbook.features.finance;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import vn.chuongpl.badbook.features.venue.Venue;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface FinanceRepository extends JpaRepository<Finance, UUID> {
    Optional<Finance> findByBookingId(UUID bookingId);

    @Query("""
        SELECT f FROM Finance f
        WHERE f.booking.venue = :venue
        AND FUNCTION('TO_CHAR', CAST(f.booking.createdAt AS date), 'YYYY-MM') = :period
    """)
    List<Finance> findByVenueAndPeriod(@Param("venue") Venue venue, @Param("period") String period);
}
