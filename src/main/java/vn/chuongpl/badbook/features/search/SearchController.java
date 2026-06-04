package vn.chuongpl.badbook.features.search;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.common.PageResponse;
import vn.chuongpl.badbook.features.venue.dto.response.VenueResponse;

import java.util.List;

@RestController
@RequestMapping("/api/search")
@RequiredArgsConstructor
public class SearchController {

    private final SearchService searchService;

    @GetMapping
    public ApiResponse<PageResponse<VenueResponse>> search(
            @RequestParam(required = false) String keyword,
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        String userId = jwt != null ? jwt.getSubject() : null;
        return ApiResponse.<PageResponse<VenueResponse>>builder()
                .data(searchService.searchVenues(keyword, userId, page, size)).build();
    }

    @GetMapping("/hot")
    public ApiResponse<List<String>> getHotKeywords(@RequestParam(defaultValue = "10") int limit) {
        return ApiResponse.<List<String>>builder()
                .data(searchService.getHotKeywords(limit)).build();
    }

    @GetMapping("/history")
    public ApiResponse<List<String>> getMyHistory(@AuthenticationPrincipal Jwt jwt) {
        return ApiResponse.<List<String>>builder()
                .data(searchService.getUserSearchHistory(jwt.getSubject())).build();
    }
}
