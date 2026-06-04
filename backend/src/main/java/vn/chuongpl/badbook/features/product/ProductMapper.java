package vn.chuongpl.badbook.features.product;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import vn.chuongpl.badbook.features.product.dto.response.ProductResponse;

@Mapper(componentModel = "spring")
public interface ProductMapper {
    @Mapping(source = "venue.id", target = "venueId")
    ProductResponse toResponse(Product product);
}
