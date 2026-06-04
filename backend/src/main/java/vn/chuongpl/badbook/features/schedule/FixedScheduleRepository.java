package vn.chuongpl.badbook.features.schedule;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.chuongpl.badbook.features.user.User;

import java.util.List;
import java.util.UUID;

public interface FixedScheduleRepository extends JpaRepository<FixedSchedule, UUID> {
    List<FixedSchedule> findByUserAndStatus(User user, String status);
    List<FixedSchedule> findByStatus(String status);
}
