package vn.chuongpl.badbook.features.user;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;



@Repository
public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByName(String name);
    Optional<User> findByEmail(String email);
    Boolean existsByEmail(String email);

    long countByCreatedAtBetweenAndDeletedFalse(LocalDateTime startTime, LocalDateTime endTime);
    Optional<User> findByEmailAndDeletedFalse(String emailRequest);
//    @Query(value = "SELECT * FROM users u WHERE u.id = :id AND u.is_deleted = false", nativeQuery = true)
    Optional<User> findByIdAndDeletedFalse(@Param("id") UUID id);
    Page<User> findByRolesIn(List<String> roles , Pageable pageable);
}
