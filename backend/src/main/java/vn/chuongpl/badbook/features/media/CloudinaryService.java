package vn.chuongpl.badbook.features.media;

import com.cloudinary.Cloudinary;
import lombok.RequiredArgsConstructor;
import org.mapstruct.Named;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class CloudinaryService {

    private final Cloudinary cloudinary;

    public String uploadFile(MultipartFile file, String folder) throws IOException {
        Map<String, Object> result = cloudinary.uploader().upload(
                file.getBytes(),
                Map.of("resource_type", "auto", "folder", "badbook/" + folder)
        );
        return (String) result.get("public_id");
    }

    public void deleteFile(String publicId) throws IOException {
        cloudinary.uploader().destroy(publicId, Map.of("resource_type", "image"));
    }

    @Named("generateUrl")
    public String generateUrl(String publicId) {
        if (publicId == null) return null;
        return cloudinary.url().secure(true).generate(publicId);
    }
}
