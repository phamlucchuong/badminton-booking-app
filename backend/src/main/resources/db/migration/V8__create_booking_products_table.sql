CREATE TABLE booking_products (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id   UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    product_id   UUID REFERENCES products(id),
    product_name VARCHAR(255) NOT NULL,
    quantity     INT NOT NULL CHECK (quantity > 0),
    unit_price   DECIMAL(12,2) NOT NULL CHECK (unit_price >= 0),
    total_price  DECIMAL(14,2) NOT NULL CHECK (total_price >= 0)
);

CREATE INDEX idx_booking_products_booking ON booking_products(booking_id);
