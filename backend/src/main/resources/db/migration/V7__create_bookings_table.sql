CREATE TABLE bookings (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      UUID NOT NULL REFERENCES users(id),
    court_id     UUID NOT NULL REFERENCES courts(id),
    venue_id     UUID NOT NULL REFERENCES venues(id),
    booking_date DATE NOT NULL,
    start_time   TIME NOT NULL,
    end_time     TIME NOT NULL,
    type         VARCHAR(10) NOT NULL DEFAULT 'HOURLY' CHECK (type IN ('HOURLY','FIXED')),
    status       VARCHAR(15) NOT NULL DEFAULT 'PENDING'
                     CHECK (status IN ('PENDING','CONFIRMED','IN_PROGRESS','COMPLETED','CANCELLED')),
    total_amount DECIMAL(14,2) NOT NULL CHECK (total_amount >= 0),
    notes        TEXT,
    cancel_reason TEXT,
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP
);

CREATE INDEX idx_bookings_user ON bookings(user_id);
CREATE INDEX idx_bookings_court_date ON bookings(court_id, booking_date);
CREATE INDEX idx_bookings_venue ON bookings(venue_id);
CREATE INDEX idx_bookings_status ON bookings(status);
