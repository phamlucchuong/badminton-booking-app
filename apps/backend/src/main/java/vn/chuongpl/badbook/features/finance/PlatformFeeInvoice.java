package vn.chuongpl.badbook.features.finance;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.PlatformFeeStatus;
import vn.chuongpl.badbook.features.venue.Venue;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity @Table(name = "platform_fee_invoices")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class PlatformFeeInvoice {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid") UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "venue_id", nullable = false) Venue venue;

    @Column(nullable = false, length = 7) String period;
    @Column(name = "total_bookings") int totalBookings;
    @Column(name = "total_revenue", precision = 14, scale = 2) BigDecimal totalRevenue;
    @Column(name = "fee_amount", precision = 14, scale = 2) BigDecimal feeAmount;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    @Builder.Default PlatformFeeStatus status = PlatformFeeStatus.PENDING;

    @Column(name = "due_date", nullable = false) LocalDate dueDate;
    @Column(name = "paid_at") LocalDateTime paidAt;
}
