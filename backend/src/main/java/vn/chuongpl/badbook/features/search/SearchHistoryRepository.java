package vn.chuongpl.badbook.features.search;

import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import vn.chuongpl.badbook.features.user.User;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface SearchHistoryRepository extends JpaRepository<SearchHistory, UUID> {
    Optional<SearchHistory> findByUserAndKeyword(User user, String keyword);

    @Query("SELECT s FROM SearchHistory s ORDER BY s.count DESC")
    List<SearchHistory> findHotKeywords(Pageable pageable);

    List<SearchHistory> findByUserOrderByLastSearchedAtDesc(User user);
}
