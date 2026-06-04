package vn.chuongpl.badbook.features.product;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.common.enums.ProductCategory;
import vn.chuongpl.badbook.features.venue.Venue;

import java.math.BigDecimal;
import java.util.UUID;

@Entity @Table(name = "products")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class Product {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid") UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "venue_id", nullable = false) Venue venue;

    @Column(nullable = false) String name;
    @Column(columnDefinition = "TEXT") String description;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    @Builder.Default ProductCategory category = ProductCategory.OTHER;

    @Column(nullable = false, precision = 12, scale = 2) BigDecimal price;
    @Column(nullable = false) @Builder.Default String unit = "cái";
    @Column(nullable = false) @Builder.Default int stock = 0;
    @Column(name = "image_id") String imageId;
    @Column(name = "is_active") @Builder.Default boolean active = true;
}
