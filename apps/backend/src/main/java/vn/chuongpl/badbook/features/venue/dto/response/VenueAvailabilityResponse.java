package vn.chuongpl.badbook.features.venue.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VenueAvailabilityResponse {
    LocalDate date;
    LocalTime openTime;
    LocalTime closeTime;
    List<CourtSlotResponse> courts;
}
