package vn.chuongpl.badbook.features.search;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.FieldDefaults;
import vn.chuongpl.badbook.features.user.User;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity @Table(name = "search_history")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
public class SearchHistory {

    @Id @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid") UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id") User user;

    @Column(nullable = false) String keyword;
    @Column(nullable = false) @Builder.Default int count = 1;

    @Column(name = "last_searched_at", nullable = false)
    @Builder.Default LocalDateTime lastSearchedAt = LocalDateTime.now();
}
