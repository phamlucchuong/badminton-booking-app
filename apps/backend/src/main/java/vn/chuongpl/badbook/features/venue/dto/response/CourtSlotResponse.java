package vn.chuongpl.badbook.features.venue.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CourtSlotResponse {
    String courtId;
    String courtName;
    List<SlotResponse> slots;
}
