package vn.chuongpl.badbook.features.payment;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.PaymentMethod;
import vn.chuongpl.badbook.common.enums.PaymentStatus;
import vn.chuongpl.badbook.features.booking.Booking;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity @Table(name = "payments")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class Payment {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid") UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_id", nullable = false) Booking booking;

    @Column(nullable = false, precision = 14, scale = 2) BigDecimal amount;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10) PaymentMethod method;

    @Column(name = "transaction_id") String transactionId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    @Builder.Default PaymentStatus status = PaymentStatus.PENDING;

    @Column(name = "paid_at") LocalDateTime paidAt;
}
