package vn.chuongpl.badbook.features.venue.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.DayOfWeek;
import java.time.LocalTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VenueOperatingHourRequest {
    DayOfWeek dayOfWeek;
    LocalTime openTime;
    LocalTime closeTime;
    boolean closed;
}
