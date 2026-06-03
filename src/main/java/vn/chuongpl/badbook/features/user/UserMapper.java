package vn.chuongpl.badbook.features.user;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import vn.chuongpl.badbook.features.user.dto.request.UserCreateRequest;
import vn.chuongpl.badbook.features.user.dto.request.UserUpdateRequest;
import vn.chuongpl.badbook.features.user.dto.response.UserResponse;

@Mapper(componentModel = "spring")
public interface UserMapper {
    @Mapping(target = "id" , ignore = true)
    @Mapping(target = "roles" , ignore = true)
    @Mapping(target = "imageId" , ignore = true)
    @Mapping(target = "createdAt" , ignore = true)
    @Mapping(target = "deleted" , ignore = true)
    User toUser(UserCreateRequest request);

    @Mapping(target = "deleted", expression = "java(user.isDeleted())")
    UserResponse toUserResponse(User user);

    @Mapping(target = "id" , ignore = true)
    @Mapping(target = "email" , ignore = true)
    @Mapping(target = "imageId" , ignore = true)
    @Mapping(target = "createdAt" , ignore = true)
    @Mapping(target = "deleted" , ignore = true)
    @Mapping(target = "roles" , ignore = true)
    void toUpdate(@MappingTarget User user , UserUpdateRequest request);

//    @Mapping(target = "id", source = "id")
//    @Mapping(target = "name", source = "name")
//    @Mapping(target = "phone", source = "phone")
//    @Mapping(target = "imageId" , source = "imageId")
//    InfoUserOrderResponse toInfoUserOrderResponse(User user);
}
