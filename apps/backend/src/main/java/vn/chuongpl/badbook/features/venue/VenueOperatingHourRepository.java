package vn.chuongpl.badbook.features.venue;

import org.springframework.data.jpa.repository.JpaRepository;

import java.time.DayOfWeek;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface VenueOperatingHourRepository extends JpaRepository<VenueOperatingHour, UUID> {
    List<VenueOperatingHour> findByVenue(Venue venue);

    Optional<VenueOperatingHour> findByVenueAndDayOfWeek(Venue venue, DayOfWeek dayOfWeek);
}
