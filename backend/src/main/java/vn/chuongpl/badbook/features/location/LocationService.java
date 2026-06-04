package vn.chuongpl.badbook.features.location;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.util.UriComponentsBuilder;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.location.dto.GeocodingResponse;
import vn.chuongpl.badbook.features.location.dto.GoongLocation;

@Service
@RequiredArgsConstructor
public class LocationService {

    private final WebClient goongWebClient;

    @Value("${goong.api.key}") String goongApiKey;
    @Value("${goong.api.base-url}") String goongBaseUrl;

    public GoongLocation geocode(String address) {
        String url = UriComponentsBuilder.fromHttpUrl(goongBaseUrl)
                .path("/geocode")
                .queryParam("address", address)
                .queryParam("api_key", goongApiKey)
                .build().toUriString();

        GeocodingResponse response = goongWebClient.get()
                .uri(url).retrieve()
                .bodyToMono(GeocodingResponse.class).block();

        if (response != null && "OK".equals(response.getStatus()) && !response.getResults().isEmpty()) {
            return response.getResults().get(0).getGeometry().getLocation();
        }
        throw new AppException(ErrorCode.GEOCODING_FAILED);
    }

    public String reverseGeocode(double lat, double lng) {
        String url = UriComponentsBuilder.fromHttpUrl(goongBaseUrl)
                .path("/geocode")
                .queryParam("latlng", lat + "," + lng)
                .queryParam("api_key", goongApiKey)
                .build().toUriString();

        GeocodingResponse response = goongWebClient.get()
                .uri(url).retrieve()
                .bodyToMono(GeocodingResponse.class).block();

        if (response != null && "OK".equals(response.getStatus()) && !response.getResults().isEmpty()) {
            return response.getResults().get(0).getFormattedAddress();
        }
        throw new AppException(ErrorCode.GEOCODING_FAILED);
    }
}
