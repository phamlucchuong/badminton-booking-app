CREATE TABLE search_history (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID REFERENCES users(id) ON DELETE SET NULL,
    keyword         VARCHAR(255) NOT NULL,
    count           INT NOT NULL DEFAULT 1,
    last_searched_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_search_history_keyword ON search_history(keyword);
CREATE UNIQUE INDEX idx_search_history_user_keyword ON search_history(user_id, keyword)
    WHERE user_id IS NOT NULL;
