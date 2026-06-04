package vn.chuongpl.badbook.features.product;

import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.features.product.dto.request.ProductCreateRequest;
import vn.chuongpl.badbook.features.product.dto.response.ProductResponse;

import java.util.List;

@RestController
@RequestMapping("/api/venues/{venueId}/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    @PostMapping
    @PreAuthorize("hasRole('VENUE_MANAGER')")
    public ApiResponse<ProductResponse> addProduct(@AuthenticationPrincipal Jwt jwt,
                                                    @PathVariable String venueId,
                                                    @RequestBody ProductCreateRequest request) {
        return ApiResponse.<ProductResponse>builder()
                .data(productService.addProduct(jwt.getSubject(), venueId, request)).build();
    }

    @GetMapping
    public ApiResponse<List<ProductResponse>> getProducts(@PathVariable String venueId) {
        return ApiResponse.<List<ProductResponse>>builder()
                .data(productService.getProductsByVenue(venueId)).build();
    }
}
