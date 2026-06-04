package vn.chuongpl.badbook.features.product;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.product.dto.request.ProductCreateRequest;
import vn.chuongpl.badbook.features.product.dto.response.ProductResponse;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;
import vn.chuongpl.badbook.features.venue.Venue;
import vn.chuongpl.badbook.features.venue.VenueRepository;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class ProductService {

    ProductRepository productRepository;
    VenueRepository venueRepository;
    UserRepository userRepository;
    ProductMapper productMapper;

    @Transactional
    public ProductResponse addProduct(String userId, String venueId, ProductCreateRequest request) {
        User user = findUser(userId);
        Venue venue = findVenue(venueId);
        assertOwner(venue, user);
        Product product = Product.builder()
                .venue(venue).name(request.getName()).description(request.getDescription())
                .category(request.getCategory()).price(request.getPrice())
                .unit(request.getUnit()).stock(request.getStock()).build();
        return productMapper.toResponse(productRepository.save(product));
    }

    public List<ProductResponse> getProductsByVenue(String venueId) {
        return productRepository.findByVenueAndActiveTrue(findVenue(venueId))
                .stream().map(productMapper::toResponse).toList();
    }

    @Transactional
    public void decreaseStock(String venueId, String productId, int quantity) {
        Venue venue = findVenue(venueId);
        Product product = productRepository.findByIdAndVenue(UUID.fromString(productId), venue)
                .orElseThrow(() -> new AppException(ErrorCode.PRODUCT_NOT_FOUND));
        if (product.getStock() < quantity) throw new AppException(ErrorCode.PRODUCT_OUT_OF_STOCK);
        product.setStock(product.getStock() - quantity);
        productRepository.save(product);
    }

    @Transactional
    public void increaseStock(String venueId, String productId, int quantity) {
        Venue venue = findVenue(venueId);
        Product product = productRepository.findByIdAndVenue(UUID.fromString(productId), venue)
                .orElseThrow(() -> new AppException(ErrorCode.PRODUCT_NOT_FOUND));
        product.setStock(product.getStock() + quantity);
        productRepository.save(product);
    }

    Product findProduct(String productId) {
        return productRepository.findById(UUID.fromString(productId))
                .orElseThrow(() -> new AppException(ErrorCode.PRODUCT_NOT_FOUND));
    }

    private void assertOwner(Venue venue, User user) {
        if (!venue.getOwner().getId().equals(user.getId()))
            throw new AppException(ErrorCode.VENUE_NOT_OWNED_BY_USER);
    }

    private Venue findVenue(String venueId) {
        return venueRepository.findById(UUID.fromString(venueId))
                .orElseThrow(() -> new AppException(ErrorCode.VENUE_NOT_FOUND));
    }

    private User findUser(String userId) {
        return userRepository.findById(UUID.fromString(userId))
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
    }
}
