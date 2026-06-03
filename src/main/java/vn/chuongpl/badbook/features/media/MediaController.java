package vn.chuongpl.badbook.features.media;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import vn.chuongpl.badbook.common.ApiResponse;
import vn.chuongpl.badbook.common.enums.ErrorCode;
import vn.chuongpl.badbook.common.exception.AppException;

import java.io.IOException;

@RestController
@RequestMapping("/api/media")
@RequiredArgsConstructor
public class MediaController {

    private final CloudinaryService cloudinaryService;

    @PostMapping
    public ApiResponse<String> upload(
            @RequestParam("folder") String folder,
            @RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) throw new AppException(ErrorCode.FILE_UPLOAD_FAILED);
        try {
            return ApiResponse.<String>builder()
                    .data(cloudinaryService.uploadFile(file, folder))
                    .build();
        } catch (IOException e) {
            throw new AppException(ErrorCode.FILE_UPLOAD_FAILED);
        }
    }
}
