package vn.chuongpl.badbook.features.location;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.features.location.dto.GoongLocation;

@RestController
@RequestMapping("/api/location")
@RequiredArgsConstructor
public class LocationController {

    private final LocationService locationService;

    @PostMapping("/geocode")
    public ApiResponse<GoongLocation> geocode(@RequestBody String address) {
        return ApiResponse.<GoongLocation>builder()
                .data(locationService.geocode(address)).build();
    }

    @GetMapping("/reverse-geocode")
    public ApiResponse<String> reverseGeocode(@RequestParam double lat, @RequestParam double lng) {
        return ApiResponse.<String>builder()
                .data(locationService.reverseGeocode(lat, lng)).build();
    }
}
