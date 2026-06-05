package vn.chuongpl.badbook.features.venue.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.time.LocalTime;

@Data
public class VenueUpdateRequest {
    @NotBlank
    String name;
    @NotBlank
    String address;
    Double latitude;
    Double longitude;
    String description;
    LocalTime openTime;
    LocalTime closeTime;
    String bankName;
    String bankNumber;
    String bankAccountName;
}
