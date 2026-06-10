package vn.chuongpl.badbook.features.booking;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.BookingStatus;
import vn.chuongpl.badbook.common.enums.BookingType;
import vn.chuongpl.badbook.features.court.Court;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.venue.Venue;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity @Table(name = "bookings")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class Booking {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid") UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false) User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "court_id", nullable = false) Court court;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "venue_id", nullable = false) Venue venue;

    @Column(name = "booking_date", nullable = false) LocalDate bookingDate;
    @Column(name = "start_time", nullable = false) LocalTime startTime;
    @Column(name = "end_time", nullable = false) LocalTime endTime;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    @Builder.Default BookingType type = BookingType.HOURLY;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 15)
    @Builder.Default BookingStatus status = BookingStatus.PENDING;

    @Column(name = "total_amount", nullable = false, precision = 14, scale = 2)
    BigDecimal totalAmount;

    @Column(columnDefinition = "TEXT") String notes;
    @Column(name = "cancel_reason", columnDefinition = "TEXT") String cancelReason;

    @Column(name = "created_at", updatable = false) LocalDateTime createdAt;
    @Column(name = "updated_at") LocalDateTime updatedAt;

    @OneToMany(mappedBy = "booking", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default List<BookingProduct> products = new ArrayList<>();

    @PrePersist void prePersist() { this.createdAt = LocalDateTime.now(); }
    @PreUpdate void preUpdate() { this.updatedAt = LocalDateTime.now(); }
}
