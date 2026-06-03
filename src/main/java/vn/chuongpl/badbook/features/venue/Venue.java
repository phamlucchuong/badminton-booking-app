package vn.chuongpl.badbook.features.venue;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.VenueStatus;
import vn.chuongpl.badbook.features.user.User;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.UUID;

@Entity
@Table(name = "venues")
@Getter @Setter @Builder
@NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class Venue {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid")
    UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false)
    User owner;

    @Column(nullable = false)
    String name;

    @Column(nullable = false, length = 500)
    String address;

    @Column(nullable = false, precision = 10, scale = 8)
    BigDecimal latitude;

    @Column(nullable = false, precision = 11, scale = 8)
    BigDecimal longitude;

    @Column(columnDefinition = "TEXT")
    String description;

    @Column(name = "banner_ids")
    String bannerIds;

    @Column(name = "license_id", nullable = false)
    String licenseId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    VenueStatus status = VenueStatus.PENDING;

    @Column(name = "open_time", nullable = false)
    LocalTime openTime;

    @Column(name = "close_time", nullable = false)
    LocalTime closeTime;

    @Column(name = "platform_fee_rate", nullable = false, precision = 5, scale = 4)
    @Builder.Default
    BigDecimal platformFeeRate = new BigDecimal("0.1000");

    @Column(name = "bank_name")
    String bankName;

    @Column(name = "bank_number")
    String bankNumber;

    @Column(name = "bank_account_name")
    String bankAccountName;

    @Column(name = "created_at", updatable = false)
    LocalDateTime createdAt;

    @PrePersist
    void prePersist() { this.createdAt = LocalDateTime.now(); }
}
