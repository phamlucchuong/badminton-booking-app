CREATE TABLE finances (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id          UUID NOT NULL UNIQUE REFERENCES bookings(id),
    total_amount        DECIMAL(14,2) NOT NULL,
    platform_fee_amount DECIMAL(14,2) NOT NULL,
    venue_revenue       DECIMAL(14,2) NOT NULL,
    status              VARCHAR(10) NOT NULL DEFAULT 'PENDING'
                            CHECK (status IN ('PENDING','COMPLETED','FAILED'))
);

CREATE TABLE platform_fee_invoices (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    venue_id        UUID NOT NULL REFERENCES venues(id),
    period          CHAR(7) NOT NULL,
    total_bookings  INT NOT NULL DEFAULT 0,
    total_revenue   DECIMAL(14,2) NOT NULL DEFAULT 0,
    fee_amount      DECIMAL(14,2) NOT NULL DEFAULT 0,
    status          VARCHAR(10) NOT NULL DEFAULT 'PENDING'
                        CHECK (status IN ('PENDING','PAID','OVERDUE')),
    due_date        DATE NOT NULL,
    paid_at         TIMESTAMP,
    UNIQUE (venue_id, period)
);

CREATE INDEX idx_finances_booking ON finances(booking_id);
CREATE INDEX idx_invoices_venue ON platform_fee_invoices(venue_id);
