package vn.chuongpl.badbook.features.schedule;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.features.court.Court;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.venue.Venue;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.UUID;

@Entity @Table(name = "fixed_schedules")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class FixedSchedule {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid") UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false) User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "court_id", nullable = false) Court court;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "venue_id", nullable = false) Venue venue;

    @Column(name = "days_of_week", nullable = false, length = 30) String daysOfWeek;
    @Column(name = "start_time", nullable = false) LocalTime startTime;
    @Column(name = "end_time", nullable = false) LocalTime endTime;
    @Column(name = "start_date", nullable = false) LocalDate startDate;
    @Column(name = "end_date", nullable = false) LocalDate endDate;

    @Column(nullable = false, length = 10) @Builder.Default String status = "ACTIVE";
    @Column(columnDefinition = "TEXT") String notes;

    @Column(name = "created_at", updatable = false) LocalDateTime createdAt;
    @PrePersist void prePersist() { this.createdAt = LocalDateTime.now(); }
}
