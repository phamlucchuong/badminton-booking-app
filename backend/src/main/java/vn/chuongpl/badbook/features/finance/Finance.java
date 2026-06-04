package vn.chuongpl.badbook.features.finance;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.features.booking.Booking;

import java.math.BigDecimal;
import java.util.UUID;

@Entity @Table(name = "finances")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class Finance {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid") UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_id", nullable = false, unique = true) Booking booking;

    @Column(name = "total_amount", nullable = false, precision = 14, scale = 2) BigDecimal totalAmount;
    @Column(name = "platform_fee_amount", nullable = false, precision = 14, scale = 2) BigDecimal platformFeeAmount;
    @Column(name = "venue_revenue", nullable = false, precision = 14, scale = 2) BigDecimal venueRevenue;

    @Column(nullable = false, length = 10) @Builder.Default String status = "PENDING";
}
