package vn.chuongpl.badbook.features.admin;

import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.common.PageResponse;
import vn.chuongpl.badbook.features.admin.dto.SystemStatsResponse;
import vn.chuongpl.badbook.features.finance.PlatformFeeInvoice;
import vn.chuongpl.badbook.features.user.UserService;
import vn.chuongpl.badbook.features.user.dto.request.UserCreateRequest;
import vn.chuongpl.badbook.features.user.dto.response.UserResponse;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
@PreAuthorize("hasRole('ADMIN')")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;
    private final UserService userService;

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

    @GetMapping("/users")
    public ApiResponse<PageResponse<UserResponse>> getUsers(
            @RequestParam(defaultValue = "1") Integer page) {
        return ApiResponse.<PageResponse<UserResponse>>builder()
                .data(userService.getAllUser(page)).build();
    }

    @PostMapping("/users")
    public ApiResponse<UserResponse> createUser(@RequestBody UserCreateRequest request) {
        return ApiResponse.<UserResponse>builder()
                .data(userService.createUser(request)).build();
    }

    @DeleteMapping("/users/{id}")
    public ApiResponse<Void> deleteUser(@PathVariable String id) {
        userService.deleteUser(id);
        return ApiResponse.<Void>builder().build();
    }
}
