CREATE TABLE products (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    venue_id    UUID NOT NULL REFERENCES venues(id) ON DELETE CASCADE,
    name        VARCHAR(255) NOT NULL,
    description TEXT,
    category    VARCHAR(30) NOT NULL DEFAULT 'OTHER'
                    CHECK (category IN ('RACKET_RENTAL','SHUTTLECOCK','BEVERAGE','EQUIPMENT','OTHER')),
    price       DECIMAL(12,2) NOT NULL CHECK (price >= 0),
    unit        VARCHAR(50) NOT NULL DEFAULT 'cái',
    stock       INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    image_id    VARCHAR(255),
    is_active   BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX idx_products_venue ON products(venue_id);
