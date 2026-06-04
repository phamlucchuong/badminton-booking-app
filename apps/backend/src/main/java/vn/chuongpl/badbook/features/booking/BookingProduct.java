package vn.chuongpl.badbook.features.booking;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.features.product.Product;

import java.math.BigDecimal;
import java.util.UUID;

@Entity @Table(name = "booking_products")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class BookingProduct {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid") UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "booking_id", nullable = false) Booking booking;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id") Product product;

    @Column(name = "product_name", nullable = false) String productName;
    @Column(nullable = false) int quantity;
    @Column(name = "unit_price", nullable = false, precision = 12, scale = 2) BigDecimal unitPrice;
    @Column(name = "total_price", nullable = false, precision = 14, scale = 2) BigDecimal totalPrice;
}
