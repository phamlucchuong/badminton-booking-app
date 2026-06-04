CREATE TABLE courts (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    venue_id    UUID NOT NULL REFERENCES venues(id) ON DELETE CASCADE,
    name        VARCHAR(100) NOT NULL,
    court_type  VARCHAR(20) NOT NULL DEFAULT 'STANDARD'
                    CHECK (court_type IN ('STANDARD','PREMIUM','VIP')),
    price_per_hour DECIMAL(12,2) NOT NULL CHECK (price_per_hour >= 0),
    image_ids   TEXT,
    status      VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
                    CHECK (status IN ('ACTIVE','MAINTENANCE','INACTIVE')),
    description TEXT
);

CREATE INDEX idx_courts_venue ON courts(venue_id);
CREATE INDEX idx_courts_status ON courts(status);
