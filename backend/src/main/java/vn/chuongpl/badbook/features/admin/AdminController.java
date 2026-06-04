package vn.chuongpl.badbook.features.admin;

import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.features.admin.dto.SystemStatsResponse;
import vn.chuongpl.badbook.features.finance.PlatformFeeInvoice;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
@PreAuthorize("hasRole('ADMIN')")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;

    @GetMapping("/stats")
    public ApiResponse<SystemStatsResponse> getStats() {
        return ApiResponse.<SystemStatsResponse>builder()
                .data(adminService.getSystemStats()).build();
    }

    @GetMapping("/invoices/pending")
    public ApiResponse<List<PlatformFeeInvoice>> getPendingInvoices() {
        return ApiResponse.<List<PlatformFeeInvoice>>builder()
                .data(adminService.getPendingInvoices()).build();
    }

    @PostMapping("/invoices/generate")
    public ApiResponse<PlatformFeeInvoice> generateInvoice(@RequestParam String venueId,
                                                            @RequestParam String period) {
        return ApiResponse.<PlatformFeeInvoice>builder()
                .data(adminService.generateInvoice(venueId, period)).build();
    }

    @PutMapping("/invoices/{id}/paid")
    public ApiResponse<PlatformFeeInvoice> markPaid(@PathVariable String id) {
        return ApiResponse.<PlatformFeeInvoice>builder()
                .data(adminService.markInvoicePaid(id)).build();
    }
}
