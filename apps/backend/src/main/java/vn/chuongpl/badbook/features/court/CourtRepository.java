package vn.chuongpl.badbook.features.court;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.chuongpl.badbook.common.enums.CourtStatus;
import vn.chuongpl.badbook.features.venue.Venue;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface CourtRepository extends JpaRepository<Court, UUID> {
    List<Court> findByVenueAndStatus(Venue venue, CourtStatus status);
    List<Court> findByVenue(Venue venue);
    Optional<Court> findByIdAndVenue(UUID id, Venue venue);
}
