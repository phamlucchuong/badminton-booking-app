package vn.chuongpl.badbook.features.product;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.chuongpl.badbook.features.venue.Venue;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ProductRepository extends JpaRepository<Product, UUID> {
    List<Product> findByVenueAndActiveTrue(Venue venue);
    Optional<Product> findByIdAndVenue(UUID id, Venue venue);
}
