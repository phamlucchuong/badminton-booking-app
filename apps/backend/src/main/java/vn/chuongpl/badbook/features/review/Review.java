package vn.chuongpl.badbook.features.review;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.ReviewTarget;
import vn.chuongpl.badbook.features.booking.Booking;
import vn.chuongpl.badbook.features.user.User;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity @Table(name = "reviews")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class Review {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid") UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    @JsonIgnoreProperties({"password", "roles", "deleted", "createdAt", "email", "phone", "hibernateLazyInitializer", "handler"})
    User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_id", nullable = false)
    @JsonIgnore
    Booking booking;

    @Enumerated(EnumType.STRING)
    @Column(name = "target_type", nullable = false, length = 10) ReviewTarget targetType;

    @Column(name = "target_id", nullable = false, columnDefinition = "uuid") UUID targetId;

    @Column(nullable = false) int rating;
    @Column(columnDefinition = "TEXT") String content;
    @Column(name = "reply_text", columnDefinition = "TEXT") String replyText;
    @Column(name = "reply_at") LocalDateTime replyAt;
    @Column(name = "is_deleted") @Builder.Default boolean deleted = false;

    @Column(name = "created_at", updatable = false) LocalDateTime createdAt;
    @PrePersist void prePersist() { this.createdAt = LocalDateTime.now(); }
}
