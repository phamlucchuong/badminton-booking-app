CREATE TABLE reviews (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id),
    booking_id  UUID NOT NULL REFERENCES bookings(id),
    target_type VARCHAR(10) NOT NULL CHECK (target_type IN ('VENUE','COURT')),
    target_id   UUID NOT NULL,
    rating      INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    content     TEXT,
    reply_text  TEXT,
    reply_at    TIMESTAMP,
    is_deleted  BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, booking_id, target_type)
);

CREATE INDEX idx_reviews_target ON reviews(target_type, target_id);
CREATE INDEX idx_reviews_booking ON reviews(booking_id);
