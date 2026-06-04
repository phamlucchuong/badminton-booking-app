package vn.chuongpl.badbook.features.admin.dto;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.math.BigDecimal;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class SystemStatsResponse {
    long totalUsers;
    long totalVenues;
    long activeVenues;
    long pendingVenues;
    long totalBookings;
    long completedBookings;
    BigDecimal totalPlatformRevenue;
    long pendingInvoices;
}
