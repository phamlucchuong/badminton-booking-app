package vn.chuongpl.badbook.features.search;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.chuongpl.badbook.common.PageResponse;
import vn.chuongpl.badbook.common.enums.VenueStatus;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;
import vn.chuongpl.badbook.features.venue.VenueMapper;
import vn.chuongpl.badbook.features.venue.VenueRepository;
import vn.chuongpl.badbook.features.venue.dto.response.VenueResponse;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class SearchService {

    SearchHistoryRepository searchHistoryRepository;
    VenueRepository venueRepository;
    UserRepository userRepository;
    VenueMapper venueMapper;

    @Transactional
    public PageResponse<VenueResponse> searchVenues(String keyword, String userId, int page, int size) {
        if (keyword != null && !keyword.isBlank()) {
            saveSearchHistory(keyword, userId);
        }
        var pageable = PageRequest.of(page - 1, size);
        var result = (keyword != null && !keyword.isBlank())
                ? venueRepository.findByNameContainingIgnoreCaseAndStatus(keyword, VenueStatus.ACTIVE, pageable)
                : venueRepository.findByStatus(VenueStatus.ACTIVE, pageable);

        return PageResponse.<VenueResponse>builder()
                .items(result.getContent().stream().map(venueMapper::toResponse).toList())
                .total(result.getTotalElements()).page(page).pageSize(size).totalPages(result.getTotalPages())
                .build();
    }

    public List<String> getHotKeywords(int limit) {
        return searchHistoryRepository.findHotKeywords(PageRequest.of(0, limit))
                .stream().map(SearchHistory::getKeyword).toList();
    }

    public List<String> getUserSearchHistory(String userId) {
        Optional<User> user = userRepository.findById(UUID.fromString(userId));
        if (user.isEmpty()) return List.of();
        return searchHistoryRepository.findByUserOrderByLastSearchedAtDesc(user.get())
                .stream().map(SearchHistory::getKeyword).toList();
    }

    private void saveSearchHistory(String keyword, String userId) {
        User user = (userId != null)
                ? userRepository.findById(UUID.fromString(userId)).orElse(null) : null;

        if (user != null) {
            searchHistoryRepository.findByUserAndKeyword(user, keyword).ifPresentOrElse(
                    h -> { h.setCount(h.getCount() + 1); h.setLastSearchedAt(LocalDateTime.now());
                           searchHistoryRepository.save(h); },
                    () -> searchHistoryRepository.save(
                            SearchHistory.builder().user(user).keyword(keyword).build()));
        }
    }
}
