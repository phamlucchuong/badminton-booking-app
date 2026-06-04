CREATE TABLE fixed_schedules (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id),
    court_id    UUID NOT NULL REFERENCES courts(id),
    venue_id    UUID NOT NULL REFERENCES venues(id),
    days_of_week VARCHAR(30) NOT NULL,
    start_time  TIME NOT NULL,
    end_time    TIME NOT NULL,
    start_date  DATE NOT NULL,
    end_date    DATE NOT NULL,
    status      VARCHAR(10) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','CANCELLED')),
    notes       TEXT,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_fixed_schedules_user ON fixed_schedules(user_id);
CREATE INDEX idx_fixed_schedules_court ON fixed_schedules(court_id);
