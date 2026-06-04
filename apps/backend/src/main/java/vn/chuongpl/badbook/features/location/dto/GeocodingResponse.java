package vn.chuongpl.badbook.features.location.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.List;

@Data
public class GeocodingResponse {
    private String status;
    private List<Result> results;

    @Data
    public static class Result {
        @JsonProperty("formatted_address")
        private String formattedAddress;
        private Geometry geometry;
    }

    @Data
    public static class Geometry {
        private GoongLocation location;
    }
}
