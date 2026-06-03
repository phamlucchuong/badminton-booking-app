package vn.chuongpl.badbook.features.venue;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import vn.chuongpl.badbook.common.enums.VenueStatus;
import vn.chuongpl.badbook.features.user.User;

import java.util.Optional;
import java.util.UUID;

public interface VenueRepository extends JpaRepository<Venue, UUID> {
    boolean existsByOwner(User owner);
    Optional<Venue> findByOwner(User owner);
    Page<Venue> findByStatus(VenueStatus status, Pageable pageable);
    Page<Venue> findByNameContainingIgnoreCaseAndStatus(String name, VenueStatus status, Pageable pageable);
}
