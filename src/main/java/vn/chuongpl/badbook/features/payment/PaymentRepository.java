package vn.chuongpl.badbook.features.payment;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.chuongpl.badbook.features.booking.Booking;

import java.util.Optional;
import java.util.UUID;

public interface PaymentRepository extends JpaRepository<Payment, UUID> {
    Optional<Payment> findByBooking(Booking booking);
}
