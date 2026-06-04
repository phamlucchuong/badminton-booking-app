package vn.chuongpl.badbook.features.booking;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface BookingProductRepository extends JpaRepository<BookingProduct, UUID> {}
