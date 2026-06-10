package vn.chuongpl.badbook.features.product;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.product.dto.request.ProductCreateRequest;
import vn.chuongpl.badbook.features.product.dto.response.ProductResponse;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;
import vn.chuongpl.badbook.features.venue.Venue;
import vn.chuongpl.badbook.features.venue.VenueRepository;

import java.math.BigDecimal;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ProductServiceTest {

    @Mock ProductRepository productRepository;
    @Mock VenueRepository venueRepository;
    @Mock UserRepository userRepository;
    @Mock ProductMapper productMapper;
    @InjectMocks ProductService productService;

    @Test
    void addProduct_successForOwner() {
        UUID userId = UUID.randomUUID(), venueId = UUID.randomUUID();
        User owner = User.builder().id(userId).build();
        Venue venue = Venue.builder().id(venueId).owner(owner).build();
        when(userRepository.findById(userId)).thenReturn(Optional.of(owner));
        when(venueRepository.findById(venueId)).thenReturn(Optional.of(venue));
        when(productRepository.save(any())).thenAnswer(i -> i.getArgument(0));
        when(productMapper.toResponse(any())).thenReturn(ProductResponse.builder().name("Vợt A").build());

        ProductResponse result = productService.addProduct(userId.toString(), venueId.toString(),
                ProductCreateRequest.builder().name("Vợt A").price(new BigDecimal("50000")).unit("cái").stock(10).build());
        assertThat(result.getName()).isEqualTo("Vợt A");
    }

    @Test
    void decreaseStock_throwsWhenOutOfStock() {
        UUID productId = UUID.randomUUID(), venueId = UUID.randomUUID();
        Venue venue = Venue.builder().id(venueId).build();
        Product product = Product.builder().id(productId).venue(venue).stock(0).build();
        when(venueRepository.findById(venueId)).thenReturn(Optional.of(venue));
        when(productRepository.findByIdAndVenue(productId, venue)).thenReturn(Optional.of(product));

        assertThatThrownBy(() -> productService.decreaseStock(venueId.toString(), productId.toString(), 1))
                .isInstanceOf(AppException.class);
    }
}
