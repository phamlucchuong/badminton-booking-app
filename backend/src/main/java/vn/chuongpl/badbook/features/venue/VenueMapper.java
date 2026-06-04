package vn.chuongpl.badbook.features.venue;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import vn.chuongpl.badbook.features.venue.dto.response.VenueResponse;

@Mapper(componentModel = "spring")
public interface VenueMapper {

    @Mapping(source = "owner.name", target = "ownerName")
    VenueResponse toResponse(Venue venue);
}
