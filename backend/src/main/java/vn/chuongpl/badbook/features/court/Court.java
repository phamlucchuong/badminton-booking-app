package vn.chuongpl.badbook.features.court;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.CourtStatus;
import vn.chuongpl.badbook.common.enums.CourtType;
import vn.chuongpl.badbook.features.venue.Venue;

import java.math.BigDecimal;
import java.util.UUID;

@Entity @Table(name = "courts")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class Court {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid") UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "venue_id", nullable = false) Venue venue;

    @Column(nullable = false) String name;

    @Enumerated(EnumType.STRING)
    @Column(name = "court_type", nullable = false, length = 20)
    @Builder.Default CourtType courtType = CourtType.STANDARD;

    @Column(name = "price_per_hour", nullable = false, precision = 12, scale = 2)
    BigDecimal pricePerHour;

    @Column(name = "image_ids") String imageIds;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default CourtStatus status = CourtStatus.ACTIVE;

    @Column(columnDefinition = "TEXT") String description;
}
