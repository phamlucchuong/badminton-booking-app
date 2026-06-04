package vn.chuongpl.badbook.features.review;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import vn.chuongpl.badbook.common.enums.ReviewTarget;
import vn.chuongpl.badbook.features.booking.Booking;
import vn.chuongpl.badbook.features.user.User;

import java.util.Optional;
import java.util.UUID;

public interface ReviewRepository extends JpaRepository<Review, UUID> {
    boolean existsByUserAndBookingAndTargetType(User user, Booking booking, ReviewTarget targetType);
    Page<Review> findByTargetTypeAndTargetIdAndDeletedFalse(ReviewTarget type, UUID targetId, Pageable pageable);
    Optional<Review> findByIdAndDeletedFalse(UUID id);
}
