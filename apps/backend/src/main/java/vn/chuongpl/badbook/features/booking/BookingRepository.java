package vn.chuongpl.badbook.features.booking;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import vn.chuongpl.badbook.common.enums.BookingStatus;
import vn.chuongpl.badbook.features.court.Court;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.venue.Venue;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

public interface BookingRepository extends JpaRepository<Booking, UUID> {

    @Query("""
        SELECT COUNT(b) > 0 FROM Booking b
        WHERE b.court = :court
        AND b.bookingDate = :date
        AND b.status IN ('CONFIRMED', 'IN_PROGRESS')
        AND b.startTime < :endTime
        AND b.endTime > :startTime
    """)
    boolean existsConflict(@Param("court") Court court,
                           @Param("date") LocalDate date,
                           @Param("startTime") LocalTime startTime,
                           @Param("endTime") LocalTime endTime);

    Page<Booking> findByUser(User user, Pageable pageable);
    Page<Booking> findByVenue(Venue venue, Pageable pageable);
    List<Booking> findByVenueAndStatusAndBookingDate(Venue venue, BookingStatus status, LocalDate date);

    @Query("""
        SELECT b FROM Booking b
        WHERE b.court = :court
        AND b.bookingDate = :date
        AND b.status IN ('PENDING', 'CONFIRMED')
    """)
    List<Booking> findActiveBookingsForCourtOnDate(@Param("court") Court court,
                                                   @Param("date") LocalDate date);
}
