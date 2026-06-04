package vn.chuongpl.badbook.features.role;

import java.util.Optional;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RoleRepository  extends JpaRepository<Role , String>{

    @EntityGraph(attributePaths = {"permission"})
    Optional<Role> findByName(String name);
}
