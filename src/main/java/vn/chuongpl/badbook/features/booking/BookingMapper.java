package vn.chuongpl.badbook.features.booking;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import vn.chuongpl.badbook.features.booking.dto.response.BookingResponse;

@Mapper(componentModel = "spring")
public interface BookingMapper {

    @Mapping(source = "user.name", target = "userName")
    @Mapping(source = "court.name", target = "courtName")
    @Mapping(source = "venue.name", target = "venueName")
    @Mapping(source = "products", target = "products")
    BookingResponse toResponse(Booking booking);

    @Mapping(source = "productName", target = "productName")
    BookingResponse.BookingProductResponse toProductResponse(BookingProduct bp);
}
