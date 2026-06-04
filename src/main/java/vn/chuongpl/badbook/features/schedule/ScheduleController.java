package vn.chuongpl.badbook.features.schedule;

import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.features.schedule.dto.FixedScheduleCreateRequest;

import java.util.List;

@RestController
@RequestMapping("/api/schedules")
@RequiredArgsConstructor
public class ScheduleController {

    private final ScheduleService scheduleService;

    @PostMapping
    @PreAuthorize("hasRole('USER')")
    public ApiResponse<FixedSchedule> createSchedule(@AuthenticationPrincipal Jwt jwt,
                                                      @RequestBody FixedScheduleCreateRequest request) {
        return ApiResponse.<FixedSchedule>builder()
                .data(scheduleService.createSchedule(jwt.getSubject(), request)).build();
    }

    @GetMapping("/my")
    @PreAuthorize("hasRole('USER')")
    public ApiResponse<List<FixedSchedule>> getMySchedules(@AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.<List<FixedSchedule>>builder()
                .data(scheduleService.getUserSchedules(jwt.getSubject())).build();
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('USER')")
    public ApiResponse<Void> cancelSchedule(@AuthenticationPrincipal Jwt jwt, @PathVariable String id) {
        scheduleService.cancelSchedule(id, jwt.getSubject());
        return ApiResponse.<Void>builder().message("Đã hủy lịch cố định").build();
    }
}
