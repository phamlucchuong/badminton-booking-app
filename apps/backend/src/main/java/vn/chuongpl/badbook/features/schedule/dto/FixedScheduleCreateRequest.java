package vn.chuongpl.badbook.features.schedule.dto;

import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class FixedScheduleCreateRequest {
    String courtId;
    String venueId;
    List<String> daysOfWeek;
    LocalTime startTime;
    LocalTime endTime;
    LocalDate startDate;
    LocalDate endDate;
    String notes;
}
