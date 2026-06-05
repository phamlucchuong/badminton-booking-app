package vn.chuongpl.badbook.features.venue.dto.response;

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
public class VenueOperatingHourResponse {
    DayOfWeek dayOfWeek;
    LocalTime openTime;
    LocalTime closeTime;
    boolean closed;
}
