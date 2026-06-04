CREATE TABLE payments (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id      UUID NOT NULL REFERENCES bookings(id),
    amount          DECIMAL(14,2) NOT NULL CHECK (amount >= 0),
    method          VARCHAR(10) NOT NULL CHECK (method IN ('VNPAY','CASH')),
    transaction_id  VARCHAR(255),
    status          VARCHAR(10) NOT NULL DEFAULT 'PENDING'
                        CHECK (status IN ('PENDING','SUCCESS','FAILED','REFUNDED')),
    paid_at         TIMESTAMP
);

CREATE INDEX idx_payments_booking ON payments(booking_id);
