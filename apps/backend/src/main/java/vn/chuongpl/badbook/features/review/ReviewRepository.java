package vn.chuongpl.badbook.features.review;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import vn.chuongpl.badbook.common.enums.ReviewTarget;
import vn.chuongpl.badbook.features.booking.Booking;
import vn.chuongpl.badbook.features.user.User;

import java.util.Optional;
import java.util.UUID;

public interface ReviewRepository extends JpaRepository<Review, UUID> {
    boolean existsByUserAndBookingAndTargetType(User user, Booking booking, ReviewTarget targetType);

    @Query(
        value = "SELECT r FROM Review r LEFT JOIN FETCH r.user WHERE r.targetType = :type AND r.targetId = :targetId AND r.deleted = false",
        countQuery = "SELECT COUNT(r) FROM Review r WHERE r.targetType = :type AND r.targetId = :targetId AND r.deleted = false"
    )
    Page<Review> findByTargetTypeAndTargetIdAndDeletedFalse(
            @Param("type") ReviewTarget type,
            @Param("targetId") UUID targetId,
            Pageable pageable);

    Optional<Review> findByIdAndDeletedFalse(UUID id);
}
