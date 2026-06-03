package vn.chuongpl.badbook.features.court;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import vn.chuongpl.badbook.features.court.dto.response.CourtResponse;

@Mapper(componentModel = "spring")
public interface CourtMapper {
    @Mapping(source = "venue.id", target = "venueId")
    @Mapping(source = "venue.name", target = "venueName")
    CourtResponse toResponse(Court court);
}
