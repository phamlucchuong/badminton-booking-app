CREATE TABLE venues (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id    UUID NOT NULL REFERENCES users(id),
    name        VARCHAR(255) NOT NULL,
    address     VARCHAR(500) NOT NULL,
    latitude    DECIMAL(10,8) NOT NULL,
    longitude   DECIMAL(11,8) NOT NULL,
    description TEXT,
    banner_ids  TEXT,
    license_id  VARCHAR(255) NOT NULL,
    status      VARCHAR(20) NOT NULL DEFAULT 'PENDING'
                    CHECK (status IN ('PENDING','ACTIVE','SUSPENDED','REJECTED')),
    open_time   TIME NOT NULL,
    close_time  TIME NOT NULL,
    platform_fee_rate DECIMAL(5,4) NOT NULL DEFAULT 0.1000,
    bank_name   VARCHAR(100),
    bank_number VARCHAR(50),
    bank_account_name VARCHAR(100),
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_venues_owner ON venues(owner_id);
CREATE INDEX idx_venues_status ON venues(status);
