-- Development/demo seed for 20 badminton venues mapped from ALOBO public venue pages.
-- Password for seeded venue-manager accounts matches the local admin seed password: Admin@123456.
-- 24/7 or 24:00 schedules are normalized to 23:30 because the current schema stores same-day open_time/close_time only.

INSERT INTO roles (name, description) VALUES
  ('ADMIN', 'Quản trị viên hệ thống'),
  ('VENUE_MANAGER', 'Chủ sân cầu lông seed ALOBO'),
  ('USER', 'Người dùng')
ON CONFLICT (name) DO NOTHING;

-- Demo user for quick login
-- Email: demo.user@badbook.local
-- Password: Admin@123456
INSERT INTO users (id, name, email, password, phone, image_id, created_at, is_deleted) VALUES
  ('00000000-0000-0000-0000-000000000001', 'Demo User', 'user@gmail.com', '$2a$10$.Kg4C4UFpowiqgkHbCYhPuh3hKZkgFApkQ7H4kJKGpmIKSYLndJI6', '0900000001', NULL, CURRENT_TIMESTAMP, FALSE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  password = EXCLUDED.password,
  phone = EXCLUDED.phone,
  is_deleted = FALSE;
INSERT INTO user_roles (user_id, role_name) VALUES ('00000000-0000-0000-0000-000000000001', 'USER') ON CONFLICT DO NOTHING;

-- 01. Sân cầu lông Viện 354
-- Sources: https://www.alobo.vn/san-cau-long-ha-noi/
-- Booking URL: https://datlich.alobo.vn/san/sport_ntd_swin_benh_vien_354
INSERT INTO users (id, name, email, password, phone, image_id, created_at, is_deleted) VALUES
  ('00000000-0000-0000-0000-000000000101', 'Quản lý Sân cầu lông Viện 354', 'venue@badbook.com', '$2a$10$.Kg4C4UFpowiqgkHbCYhPuh3hKZkgFApkQ7H4kJKGpmIKSYLndJI6', '02437626547', NULL, CURRENT_TIMESTAMP, FALSE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  password = EXCLUDED.password,
  phone = EXCLUDED.phone,
  is_deleted = FALSE;
INSERT INTO user_roles (user_id, role_name) VALUES ('00000000-0000-0000-0000-000000000101', 'VENUE_MANAGER') ON CONFLICT DO NOTHING;
INSERT INTO venues (id, owner_id, name, address, latitude, longitude, description, banner_ids, license_id, status, open_time, close_time, platform_fee_rate, bank_name, bank_number, bank_account_name, created_at) VALUES
  ('00000000-0000-0000-0000-000000000201', '00000000-0000-0000-0000-000000000101', 'Sân cầu lông Viện 354', '120 Đốc Ngữ, Ba Đình, Hà Nội', 21.04010000, 105.81080000, 'Sân cầu lông Viện 354 nổi bật với sàn gỗ chất lượng cao, ánh sáng tốt, khu nghỉ ngơi và tủ để đồ sạch sẽ.', 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674948/badbook/alobo-seed/san-cau-long-vien-354.jpg', 'ALOBO-SEED-354', 'ACTIVE', '06:00', '22:00', 0.1000, 'Vietcombank', '190000000001', 'QUẢN LÝ SÂN CẦU LÔNG VIỆN 354', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET
  owner_id = EXCLUDED.owner_id,
  name = EXCLUDED.name,
  address = EXCLUDED.address,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude,
  description = EXCLUDED.description,
  banner_ids = EXCLUDED.banner_ids,
  license_id = EXCLUDED.license_id,
  status = EXCLUDED.status,
  open_time = EXCLUDED.open_time,
  close_time = EXCLUDED.close_time,
  platform_fee_rate = EXCLUDED.platform_fee_rate,
  bank_name = EXCLUDED.bank_name,
  bank_number = EXCLUDED.bank_number,
  bank_account_name = EXCLUDED.bank_account_name;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020011', '00000000-0000-0000-0000-000000000201', 'MONDAY', '06:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020012', '00000000-0000-0000-0000-000000000201', 'TUESDAY', '06:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020013', '00000000-0000-0000-0000-000000000201', 'WEDNESDAY', '06:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020014', '00000000-0000-0000-0000-000000000201', 'THURSDAY', '06:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020015', '00000000-0000-0000-0000-000000000201', 'FRIDAY', '06:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020016', '00000000-0000-0000-0000-000000000201', 'SATURDAY', '06:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020017', '00000000-0000-0000-0000-000000000201', 'SUNDAY', '06:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100101', '00000000-0000-0000-0000-000000000201', 'Sân 1', 'STANDARD', 140000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674948/badbook/alobo-seed/san-cau-long-vien-354.jpg', 'ACTIVE', 'Sân cầu lông Viện 354 - sân số 1') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100102', '00000000-0000-0000-0000-000000000201', 'Sân 2', 'STANDARD', 140000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674948/badbook/alobo-seed/san-cau-long-vien-354.jpg', 'ACTIVE', 'Sân cầu lông Viện 354 - sân số 2') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100103', '00000000-0000-0000-0000-000000000201', 'Sân 3', 'STANDARD', 140000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674948/badbook/alobo-seed/san-cau-long-vien-354.jpg', 'ACTIVE', 'Sân cầu lông Viện 354 - sân số 3') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100104', '00000000-0000-0000-0000-000000000201', 'Sân 4', 'STANDARD', 140000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674948/badbook/alobo-seed/san-cau-long-vien-354.jpg', 'ACTIVE', 'Sân cầu lông Viện 354 - sân số 4') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100105', '00000000-0000-0000-0000-000000000201', 'Sân 5', 'STANDARD', 140000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674948/badbook/alobo-seed/san-cau-long-vien-354.jpg', 'ACTIVE', 'Sân cầu lông Viện 354 - sân số 5') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100106', '00000000-0000-0000-0000-000000000201', 'Sân 6', 'STANDARD', 140000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674948/badbook/alobo-seed/san-cau-long-vien-354.jpg', 'ACTIVE', 'Sân cầu lông Viện 354 - sân số 6') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;

-- 02. Sân cầu lông Nhà văn hoá Mai Dịch
-- Sources: https://www.alobo.vn/san-cau-long-ha-noi/
-- Booking URL: https://datlich.alobo.vn/san/sport_le_nguyen_cn3
INSERT INTO users (id, name, email, password, phone, image_id, created_at, is_deleted) VALUES
  ('00000000-0000-0000-0000-000000000102', 'Quản lý Sân cầu lông Nhà văn hoá Mai Dịch', 'seed.alobo.mai-dich@badbook.local', '$2a$10$.Kg4C4UFpowiqgkHbCYhPuh3hKZkgFApkQ7H4kJKGpmIKSYLndJI6', '02437957769', NULL, CURRENT_TIMESTAMP, FALSE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  password = EXCLUDED.password,
  phone = EXCLUDED.phone,
  is_deleted = FALSE;
INSERT INTO user_roles (user_id, role_name) VALUES ('00000000-0000-0000-0000-000000000102', 'VENUE_MANAGER') ON CONFLICT DO NOTHING;
INSERT INTO venues (id, owner_id, name, address, latitude, longitude, description, banner_ids, license_id, status, open_time, close_time, platform_fee_rate, bank_name, bank_number, bank_account_name, created_at) VALUES
  ('00000000-0000-0000-0000-000000000202', '00000000-0000-0000-0000-000000000102', 'Sân cầu lông Nhà văn hoá Mai Dịch', 'Số 1 Trần Bình, Mai Dịch, Cầu Giấy, Hà Nội', 21.03670000, 105.78200000, 'Cụm sân Mai Dịch có sàn gỗ, hệ thống đèn LED đạt chuẩn, có đồ uống và khu nghỉ ngơi phù hợp chơi nhóm nhỏ.', 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674957/badbook/alobo-seed/san-cau-long-nha-van-hoa-mai-dich.png', 'ALOBO-SEED-MAIDICH', 'ACTIVE', '06:00', '22:00', 0.1000, 'Vietcombank', '190000000002', 'QUẢN LÝ SÂN CẦU LÔNG NHÀ VĂN HOÁ MAI DỊCH', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET
  owner_id = EXCLUDED.owner_id,
  name = EXCLUDED.name,
  address = EXCLUDED.address,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude,
  description = EXCLUDED.description,
  banner_ids = EXCLUDED.banner_ids,
  license_id = EXCLUDED.license_id,
  status = EXCLUDED.status,
  open_time = EXCLUDED.open_time,
  close_time = EXCLUDED.close_time,
  platform_fee_rate = EXCLUDED.platform_fee_rate,
  bank_name = EXCLUDED.bank_name,
  bank_number = EXCLUDED.bank_number,
  bank_account_name = EXCLUDED.bank_account_name;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020021', '00000000-0000-0000-0000-000000000202', 'MONDAY', '06:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020022', '00000000-0000-0000-0000-000000000202', 'TUESDAY', '06:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020023', '00000000-0000-0000-0000-000000000202', 'WEDNESDAY', '06:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020024', '00000000-0000-0000-0000-000000000202', 'THURSDAY', '06:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020025', '00000000-0000-0000-0000-000000000202', 'FRIDAY', '06:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020026', '00000000-0000-0000-0000-000000000202', 'SATURDAY', '06:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020027', '00000000-0000-0000-0000-000000000202', 'SUNDAY', '06:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100201', '00000000-0000-0000-0000-000000000202', 'Sân 1', 'STANDARD', 140000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674957/badbook/alobo-seed/san-cau-long-nha-van-hoa-mai-dich.png', 'ACTIVE', 'Sân cầu lông Nhà văn hoá Mai Dịch - sân số 1') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100202', '00000000-0000-0000-0000-000000000202', 'Sân 2', 'STANDARD', 140000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674957/badbook/alobo-seed/san-cau-long-nha-van-hoa-mai-dich.png', 'ACTIVE', 'Sân cầu lông Nhà văn hoá Mai Dịch - sân số 2') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100203', '00000000-0000-0000-0000-000000000202', 'Sân 3', 'STANDARD', 140000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674957/badbook/alobo-seed/san-cau-long-nha-van-hoa-mai-dich.png', 'ACTIVE', 'Sân cầu lông Nhà văn hoá Mai Dịch - sân số 3') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;

-- 03. Sân 521 Minh Khai
-- Sources: https://www.alobo.vn/san-cau-long-ha-noi/
-- Booking URL: https://datlich.alobo.vn/san/sport_ong_map_pickleball
INSERT INTO users (id, name, email, password, phone, image_id, created_at, is_deleted) VALUES
  ('00000000-0000-0000-0000-000000000103', 'Quản lý Sân 521 Minh Khai', 'seed.alobo.521-minh-khai@badbook.local', '$2a$10$.Kg4C4UFpowiqgkHbCYhPuh3hKZkgFApkQ7H4kJKGpmIKSYLndJI6', '0936129898', NULL, CURRENT_TIMESTAMP, FALSE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  password = EXCLUDED.password,
  phone = EXCLUDED.phone,
  is_deleted = FALSE;
INSERT INTO user_roles (user_id, role_name) VALUES ('00000000-0000-0000-0000-000000000103', 'VENUE_MANAGER') ON CONFLICT DO NOTHING;
INSERT INTO venues (id, owner_id, name, address, latitude, longitude, description, banner_ids, license_id, status, open_time, close_time, platform_fee_rate, bank_name, bank_number, bank_account_name, created_at) VALUES
  ('00000000-0000-0000-0000-000000000203', '00000000-0000-0000-0000-000000000103', 'Sân 521 Minh Khai', '521 Minh Khai, Vĩnh Phú, Hai Bà Trưng, Hà Nội', 20.99860000, 105.86890000, 'Sân 521 Minh Khai có 6 sân nhỏ gọn ở tầng 3, phù hợp nhóm sinh viên và người chơi cần giá giờ thấp điểm tốt.', 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674960/badbook/alobo-seed/san-521-minh-khai.jpg', 'ALOBO-SEED-MINHKHAI', 'ACTIVE', '06:00', '23:00', 0.1000, 'Vietcombank', '190000000003', 'QUẢN LÝ SÂN 521 MINH KHAI', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET
  owner_id = EXCLUDED.owner_id,
  name = EXCLUDED.name,
  address = EXCLUDED.address,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude,
  description = EXCLUDED.description,
  banner_ids = EXCLUDED.banner_ids,
  license_id = EXCLUDED.license_id,
  status = EXCLUDED.status,
  open_time = EXCLUDED.open_time,
  close_time = EXCLUDED.close_time,
  platform_fee_rate = EXCLUDED.platform_fee_rate,
  bank_name = EXCLUDED.bank_name,
  bank_number = EXCLUDED.bank_number,
  bank_account_name = EXCLUDED.bank_account_name;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020031', '00000000-0000-0000-0000-000000000203', 'MONDAY', '06:00', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020032', '00000000-0000-0000-0000-000000000203', 'TUESDAY', '06:00', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020033', '00000000-0000-0000-0000-000000000203', 'WEDNESDAY', '06:00', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020034', '00000000-0000-0000-0000-000000000203', 'THURSDAY', '06:00', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020035', '00000000-0000-0000-0000-000000000203', 'FRIDAY', '06:00', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020036', '00000000-0000-0000-0000-000000000203', 'SATURDAY', '06:00', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020037', '00000000-0000-0000-0000-000000000203', 'SUNDAY', '06:00', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100301', '00000000-0000-0000-0000-000000000203', 'Sân 1', 'STANDARD', 90000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674960/badbook/alobo-seed/san-521-minh-khai.jpg', 'ACTIVE', 'Sân 521 Minh Khai - sân số 1') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100302', '00000000-0000-0000-0000-000000000203', 'Sân 2', 'STANDARD', 90000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674960/badbook/alobo-seed/san-521-minh-khai.jpg', 'ACTIVE', 'Sân 521 Minh Khai - sân số 2') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100303', '00000000-0000-0000-0000-000000000203', 'Sân 3', 'STANDARD', 90000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674960/badbook/alobo-seed/san-521-minh-khai.jpg', 'ACTIVE', 'Sân 521 Minh Khai - sân số 3') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100304', '00000000-0000-0000-0000-000000000203', 'Sân 4', 'STANDARD', 90000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674960/badbook/alobo-seed/san-521-minh-khai.jpg', 'ACTIVE', 'Sân 521 Minh Khai - sân số 4') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100305', '00000000-0000-0000-0000-000000000203', 'Sân 5', 'STANDARD', 90000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674960/badbook/alobo-seed/san-521-minh-khai.jpg', 'ACTIVE', 'Sân 521 Minh Khai - sân số 5') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100306', '00000000-0000-0000-0000-000000000203', 'Sân 6', 'STANDARD', 90000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674960/badbook/alobo-seed/san-521-minh-khai.jpg', 'ACTIVE', 'Sân 521 Minh Khai - sân số 6') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;

-- 04. Sân cầu lông BMC Club
-- Sources: https://www.alobo.vn/san-cau-long-ha-noi/ | https://www.alobo.vn/san-cau-long-bmc-ung-dung-alobo/
-- Booking URL: https://datlich.alobo.vn/san/sport_san_cau_long_bmc
INSERT INTO users (id, name, email, password, phone, image_id, created_at, is_deleted) VALUES
  ('00000000-0000-0000-0000-000000000104', 'Quản lý Sân cầu lông BMC Club', 'seed.alobo.bmc-club@badbook.local', '$2a$10$.Kg4C4UFpowiqgkHbCYhPuh3hKZkgFApkQ7H4kJKGpmIKSYLndJI6', '0528262222', NULL, CURRENT_TIMESTAMP, FALSE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  password = EXCLUDED.password,
  phone = EXCLUDED.phone,
  is_deleted = FALSE;
INSERT INTO user_roles (user_id, role_name) VALUES ('00000000-0000-0000-0000-000000000104', 'VENUE_MANAGER') ON CONFLICT DO NOTHING;
INSERT INTO venues (id, owner_id, name, address, latitude, longitude, description, banner_ids, license_id, status, open_time, close_time, platform_fee_rate, bank_name, bank_number, bank_account_name, created_at) VALUES
  ('00000000-0000-0000-0000-000000000204', '00000000-0000-0000-0000-000000000104', 'Sân cầu lông BMC Club', 'Ngách 86 Ngõ 286 Nguyễn Xiển, Tân Triều, Thanh Trì, Hà Nội', 20.95450000, 105.81580000, 'BMC Club là cụm sân quy mô lớn với mặt sân PVC chuẩn thi đấu, phòng tắm nước nóng và bãi giữ xe miễn phí.', 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674963/badbook/alobo-seed/san-cau-long-bmc-club.jpg', 'ALOBO-SEED-BMC', 'ACTIVE', '00:00', '23:30', 0.1000, 'Vietcombank', '190000000004', 'QUẢN LÝ SÂN CẦU LÔNG BMC CLUB', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET
  owner_id = EXCLUDED.owner_id,
  name = EXCLUDED.name,
  address = EXCLUDED.address,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude,
  description = EXCLUDED.description,
  banner_ids = EXCLUDED.banner_ids,
  license_id = EXCLUDED.license_id,
  status = EXCLUDED.status,
  open_time = EXCLUDED.open_time,
  close_time = EXCLUDED.close_time,
  platform_fee_rate = EXCLUDED.platform_fee_rate,
  bank_name = EXCLUDED.bank_name,
  bank_number = EXCLUDED.bank_number,
  bank_account_name = EXCLUDED.bank_account_name;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020041', '00000000-0000-0000-0000-000000000204', 'MONDAY', '00:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020042', '00000000-0000-0000-0000-000000000204', 'TUESDAY', '00:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020043', '00000000-0000-0000-0000-000000000204', 'WEDNESDAY', '00:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020044', '00000000-0000-0000-0000-000000000204', 'THURSDAY', '00:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020045', '00000000-0000-0000-0000-000000000204', 'FRIDAY', '00:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020046', '00000000-0000-0000-0000-000000000204', 'SATURDAY', '00:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020047', '00000000-0000-0000-0000-000000000204', 'SUNDAY', '00:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100401', '00000000-0000-0000-0000-000000000204', 'Sân 1', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674963/badbook/alobo-seed/san-cau-long-bmc-club.jpg', 'ACTIVE', 'Sân cầu lông BMC Club - sân số 1') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100402', '00000000-0000-0000-0000-000000000204', 'Sân 2', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674963/badbook/alobo-seed/san-cau-long-bmc-club.jpg', 'ACTIVE', 'Sân cầu lông BMC Club - sân số 2') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100403', '00000000-0000-0000-0000-000000000204', 'Sân 3', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674963/badbook/alobo-seed/san-cau-long-bmc-club.jpg', 'ACTIVE', 'Sân cầu lông BMC Club - sân số 3') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100404', '00000000-0000-0000-0000-000000000204', 'Sân 4', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674963/badbook/alobo-seed/san-cau-long-bmc-club.jpg', 'ACTIVE', 'Sân cầu lông BMC Club - sân số 4') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100405', '00000000-0000-0000-0000-000000000204', 'Sân 5', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674963/badbook/alobo-seed/san-cau-long-bmc-club.jpg', 'ACTIVE', 'Sân cầu lông BMC Club - sân số 5') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100406', '00000000-0000-0000-0000-000000000204', 'Sân 6', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674963/badbook/alobo-seed/san-cau-long-bmc-club.jpg', 'ACTIVE', 'Sân cầu lông BMC Club - sân số 6') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100407', '00000000-0000-0000-0000-000000000204', 'Sân 7', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674963/badbook/alobo-seed/san-cau-long-bmc-club.jpg', 'ACTIVE', 'Sân cầu lông BMC Club - sân số 7') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100408', '00000000-0000-0000-0000-000000000204', 'Sân 8', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674963/badbook/alobo-seed/san-cau-long-bmc-club.jpg', 'ACTIVE', 'Sân cầu lông BMC Club - sân số 8') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100409', '00000000-0000-0000-0000-000000000204', 'Sân 9', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674963/badbook/alobo-seed/san-cau-long-bmc-club.jpg', 'ACTIVE', 'Sân cầu lông BMC Club - sân số 9') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100410', '00000000-0000-0000-0000-000000000204', 'Sân 10', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674963/badbook/alobo-seed/san-cau-long-bmc-club.jpg', 'ACTIVE', 'Sân cầu lông BMC Club - sân số 10') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100411', '00000000-0000-0000-0000-000000000204', 'Sân 11', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674963/badbook/alobo-seed/san-cau-long-bmc-club.jpg', 'ACTIVE', 'Sân cầu lông BMC Club - sân số 11') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100412', '00000000-0000-0000-0000-000000000204', 'Sân 12', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674963/badbook/alobo-seed/san-cau-long-bmc-club.jpg', 'ACTIVE', 'Sân cầu lông BMC Club - sân số 12') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100413', '00000000-0000-0000-0000-000000000204', 'Sân 13', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674963/badbook/alobo-seed/san-cau-long-bmc-club.jpg', 'ACTIVE', 'Sân cầu lông BMC Club - sân số 13') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100414', '00000000-0000-0000-0000-000000000204', 'Sân 14', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674963/badbook/alobo-seed/san-cau-long-bmc-club.jpg', 'ACTIVE', 'Sân cầu lông BMC Club - sân số 14') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;

-- 05. Sân cầu lông HG
-- Sources: https://www.alobo.vn/san-cau-long-ha-noi/
-- Booking URL: https://datlich.alobo.vn/san/sport_hg_badminton
INSERT INTO users (id, name, email, password, phone, image_id, created_at, is_deleted) VALUES
  ('00000000-0000-0000-0000-000000000105', 'Quản lý Sân cầu lông HG', 'seed.alobo.hg-badminton@badbook.local', '$2a$10$.Kg4C4UFpowiqgkHbCYhPuh3hKZkgFApkQ7H4kJKGpmIKSYLndJI6', '0900000105', NULL, CURRENT_TIMESTAMP, FALSE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  password = EXCLUDED.password,
  phone = EXCLUDED.phone,
  is_deleted = FALSE;
INSERT INTO user_roles (user_id, role_name) VALUES ('00000000-0000-0000-0000-000000000105', 'VENUE_MANAGER') ON CONFLICT DO NOTHING;
INSERT INTO venues (id, owner_id, name, address, latitude, longitude, description, banner_ids, license_id, status, open_time, close_time, platform_fee_rate, bank_name, bank_number, bank_account_name, created_at) VALUES
  ('00000000-0000-0000-0000-000000000205', '00000000-0000-0000-0000-000000000105', 'Sân cầu lông HG', 'Ngõ 512 Ngọc Hồi, Vĩnh Quỳnh, Thanh Trì, Hà Nội', 20.93200000, 105.84400000, 'HG có 5 sân rộng, không gian thoáng và tiện ích cơ bản, phù hợp cho chơi thường xuyên khu vực Ngọc Hồi.', 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674968/badbook/alobo-seed/san-cau-long-hg.png', 'ALOBO-SEED-HG', 'ACTIVE', '05:00', '23:30', 0.1000, 'Vietcombank', '190000000005', 'QUẢN LÝ SÂN CẦU LÔNG HG', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET
  owner_id = EXCLUDED.owner_id,
  name = EXCLUDED.name,
  address = EXCLUDED.address,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude,
  description = EXCLUDED.description,
  banner_ids = EXCLUDED.banner_ids,
  license_id = EXCLUDED.license_id,
  status = EXCLUDED.status,
  open_time = EXCLUDED.open_time,
  close_time = EXCLUDED.close_time,
  platform_fee_rate = EXCLUDED.platform_fee_rate,
  bank_name = EXCLUDED.bank_name,
  bank_number = EXCLUDED.bank_number,
  bank_account_name = EXCLUDED.bank_account_name;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020051', '00000000-0000-0000-0000-000000000205', 'MONDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020052', '00000000-0000-0000-0000-000000000205', 'TUESDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020053', '00000000-0000-0000-0000-000000000205', 'WEDNESDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020054', '00000000-0000-0000-0000-000000000205', 'THURSDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020055', '00000000-0000-0000-0000-000000000205', 'FRIDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020056', '00000000-0000-0000-0000-000000000205', 'SATURDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020057', '00000000-0000-0000-0000-000000000205', 'SUNDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100501', '00000000-0000-0000-0000-000000000205', 'Sân 1', 'STANDARD', 80000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674968/badbook/alobo-seed/san-cau-long-hg.png', 'ACTIVE', 'Sân cầu lông HG - sân số 1') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100502', '00000000-0000-0000-0000-000000000205', 'Sân 2', 'STANDARD', 80000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674968/badbook/alobo-seed/san-cau-long-hg.png', 'ACTIVE', 'Sân cầu lông HG - sân số 2') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100503', '00000000-0000-0000-0000-000000000205', 'Sân 3', 'STANDARD', 80000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674968/badbook/alobo-seed/san-cau-long-hg.png', 'ACTIVE', 'Sân cầu lông HG - sân số 3') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100504', '00000000-0000-0000-0000-000000000205', 'Sân 4', 'STANDARD', 80000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674968/badbook/alobo-seed/san-cau-long-hg.png', 'ACTIVE', 'Sân cầu lông HG - sân số 4') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100505', '00000000-0000-0000-0000-000000000205', 'Sân 5', 'STANDARD', 80000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674968/badbook/alobo-seed/san-cau-long-hg.png', 'ACTIVE', 'Sân cầu lông HG - sân số 5') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;

-- 06. Sân cầu lông TDT 314 Bùi Xương Trạch
-- Sources: https://www.alobo.vn/san-cau-long-tdt-314-bui-xuong-trach/
-- Booking URL: https://datlich.alobo.vn/san/sport_san_cau_long_tdt
INSERT INTO users (id, name, email, password, phone, image_id, created_at, is_deleted) VALUES
  ('00000000-0000-0000-0000-000000000106', 'Quản lý Sân cầu lông TDT 314 Bùi Xương Trạch', 'seed.alobo.tdt-314-bui-xuong-trach@badbook.local', '$2a$10$.Kg4C4UFpowiqgkHbCYhPuh3hKZkgFApkQ7H4kJKGpmIKSYLndJI6', '0900000106', NULL, CURRENT_TIMESTAMP, FALSE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  password = EXCLUDED.password,
  phone = EXCLUDED.phone,
  is_deleted = FALSE;
INSERT INTO user_roles (user_id, role_name) VALUES ('00000000-0000-0000-0000-000000000106', 'VENUE_MANAGER') ON CONFLICT DO NOTHING;
INSERT INTO venues (id, owner_id, name, address, latitude, longitude, description, banner_ids, license_id, status, open_time, close_time, platform_fee_rate, bank_name, bank_number, bank_account_name, created_at) VALUES
  ('00000000-0000-0000-0000-000000000206', '00000000-0000-0000-0000-000000000106', 'Sân cầu lông TDT 314 Bùi Xương Trạch', '314 Bùi Xương Trạch, Khương Đình, Thanh Xuân, Hà Nội', 20.98850000, 105.81530000, 'TDT 314 Bùi Xương Trạch là điểm hẹn cầu lông 24/7 với 10 sân thảm tiêu chuẩn và chính sách trợ giá cho học sinh, sinh viên.', 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674972/badbook/alobo-seed/san-cau-long-tdt-314-bui-xuong-trach.png', 'ALOBO-SEED-TDT314', 'ACTIVE', '00:00', '23:30', 0.1000, 'Vietcombank', '190000000006', 'QUẢN LÝ SÂN CẦU LÔNG TDT 314 BÙI XƯƠNG TRẠCH', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET
  owner_id = EXCLUDED.owner_id,
  name = EXCLUDED.name,
  address = EXCLUDED.address,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude,
  description = EXCLUDED.description,
  banner_ids = EXCLUDED.banner_ids,
  license_id = EXCLUDED.license_id,
  status = EXCLUDED.status,
  open_time = EXCLUDED.open_time,
  close_time = EXCLUDED.close_time,
  platform_fee_rate = EXCLUDED.platform_fee_rate,
  bank_name = EXCLUDED.bank_name,
  bank_number = EXCLUDED.bank_number,
  bank_account_name = EXCLUDED.bank_account_name;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020061', '00000000-0000-0000-0000-000000000206', 'MONDAY', '00:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020062', '00000000-0000-0000-0000-000000000206', 'TUESDAY', '00:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020063', '00000000-0000-0000-0000-000000000206', 'WEDNESDAY', '00:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020064', '00000000-0000-0000-0000-000000000206', 'THURSDAY', '00:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020065', '00000000-0000-0000-0000-000000000206', 'FRIDAY', '00:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020066', '00000000-0000-0000-0000-000000000206', 'SATURDAY', '00:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020067', '00000000-0000-0000-0000-000000000206', 'SUNDAY', '00:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100601', '00000000-0000-0000-0000-000000000206', 'Sân 1', 'STANDARD', 90000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674972/badbook/alobo-seed/san-cau-long-tdt-314-bui-xuong-trach.png', 'ACTIVE', 'Sân cầu lông TDT 314 Bùi Xương Trạch - sân số 1') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100602', '00000000-0000-0000-0000-000000000206', 'Sân 2', 'STANDARD', 90000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674972/badbook/alobo-seed/san-cau-long-tdt-314-bui-xuong-trach.png', 'ACTIVE', 'Sân cầu lông TDT 314 Bùi Xương Trạch - sân số 2') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100603', '00000000-0000-0000-0000-000000000206', 'Sân 3', 'STANDARD', 90000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674972/badbook/alobo-seed/san-cau-long-tdt-314-bui-xuong-trach.png', 'ACTIVE', 'Sân cầu lông TDT 314 Bùi Xương Trạch - sân số 3') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100604', '00000000-0000-0000-0000-000000000206', 'Sân 4', 'STANDARD', 90000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674972/badbook/alobo-seed/san-cau-long-tdt-314-bui-xuong-trach.png', 'ACTIVE', 'Sân cầu lông TDT 314 Bùi Xương Trạch - sân số 4') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100605', '00000000-0000-0000-0000-000000000206', 'Sân 5', 'STANDARD', 90000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674972/badbook/alobo-seed/san-cau-long-tdt-314-bui-xuong-trach.png', 'ACTIVE', 'Sân cầu lông TDT 314 Bùi Xương Trạch - sân số 5') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100606', '00000000-0000-0000-0000-000000000206', 'Sân 6', 'STANDARD', 90000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674972/badbook/alobo-seed/san-cau-long-tdt-314-bui-xuong-trach.png', 'ACTIVE', 'Sân cầu lông TDT 314 Bùi Xương Trạch - sân số 6') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100607', '00000000-0000-0000-0000-000000000206', 'Sân 7', 'STANDARD', 90000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674972/badbook/alobo-seed/san-cau-long-tdt-314-bui-xuong-trach.png', 'ACTIVE', 'Sân cầu lông TDT 314 Bùi Xương Trạch - sân số 7') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100608', '00000000-0000-0000-0000-000000000206', 'Sân 8', 'STANDARD', 90000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674972/badbook/alobo-seed/san-cau-long-tdt-314-bui-xuong-trach.png', 'ACTIVE', 'Sân cầu lông TDT 314 Bùi Xương Trạch - sân số 8') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100609', '00000000-0000-0000-0000-000000000206', 'Sân 9', 'STANDARD', 90000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674972/badbook/alobo-seed/san-cau-long-tdt-314-bui-xuong-trach.png', 'ACTIVE', 'Sân cầu lông TDT 314 Bùi Xương Trạch - sân số 9') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100610', '00000000-0000-0000-0000-000000000206', 'Sân 10', 'STANDARD', 90000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674972/badbook/alobo-seed/san-cau-long-tdt-314-bui-xuong-trach.png', 'ACTIVE', 'Sân cầu lông TDT 314 Bùi Xương Trạch - sân số 10') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;

-- 07. Sân cầu lông Eco
-- Sources: https://www.alobo.vn/dia-chi-thue-san-cau-long-tren-app-alobo/ | https://www.alobo.vn/cach-dat-san-cau-long-online-vo-cung-don-gian-qua-ung-dung-alobo/
-- Booking URL: not publicly exposed
INSERT INTO users (id, name, email, password, phone, image_id, created_at, is_deleted) VALUES
  ('00000000-0000-0000-0000-000000000107', 'Quản lý Sân cầu lông Eco', 'seed.alobo.eco-q7@badbook.local', '$2a$10$.Kg4C4UFpowiqgkHbCYhPuh3hKZkgFApkQ7H4kJKGpmIKSYLndJI6', '0973672429', NULL, CURRENT_TIMESTAMP, FALSE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  password = EXCLUDED.password,
  phone = EXCLUDED.phone,
  is_deleted = FALSE;
INSERT INTO user_roles (user_id, role_name) VALUES ('00000000-0000-0000-0000-000000000107', 'VENUE_MANAGER') ON CONFLICT DO NOTHING;
INSERT INTO venues (id, owner_id, name, address, latitude, longitude, description, banner_ids, license_id, status, open_time, close_time, platform_fee_rate, bank_name, bank_number, bank_account_name, created_at) VALUES
  ('00000000-0000-0000-0000-000000000207', '00000000-0000-0000-0000-000000000107', 'Sân cầu lông Eco', '107 Nguyễn Văn Linh, Chung cư Eco Green, phường Tân Thuận, Quận 7, TP.HCM', 10.74170000, 106.72180000, 'Eco là cụm sân quận 7 quy mô 17 sân, trần cao, ánh sáng tốt và mặt sân mới, phù hợp chơi giờ thấp điểm lẫn cao điểm.', 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674976/badbook/alobo-seed/san-cau-long-eco.jpg', 'ALOBO-SEED-ECOQ7', 'ACTIVE', '05:30', '23:00', 0.1000, 'Vietcombank', '190000000007', 'QUẢN LÝ SÂN CẦU LÔNG ECO', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET
  owner_id = EXCLUDED.owner_id,
  name = EXCLUDED.name,
  address = EXCLUDED.address,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude,
  description = EXCLUDED.description,
  banner_ids = EXCLUDED.banner_ids,
  license_id = EXCLUDED.license_id,
  status = EXCLUDED.status,
  open_time = EXCLUDED.open_time,
  close_time = EXCLUDED.close_time,
  platform_fee_rate = EXCLUDED.platform_fee_rate,
  bank_name = EXCLUDED.bank_name,
  bank_number = EXCLUDED.bank_number,
  bank_account_name = EXCLUDED.bank_account_name;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020071', '00000000-0000-0000-0000-000000000207', 'MONDAY', '05:30', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020072', '00000000-0000-0000-0000-000000000207', 'TUESDAY', '05:30', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020073', '00000000-0000-0000-0000-000000000207', 'WEDNESDAY', '05:30', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020074', '00000000-0000-0000-0000-000000000207', 'THURSDAY', '05:30', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020075', '00000000-0000-0000-0000-000000000207', 'FRIDAY', '05:30', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020076', '00000000-0000-0000-0000-000000000207', 'SATURDAY', '05:30', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020077', '00000000-0000-0000-0000-000000000207', 'SUNDAY', '05:30', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100701', '00000000-0000-0000-0000-000000000207', 'Sân 1', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674976/badbook/alobo-seed/san-cau-long-eco.jpg', 'ACTIVE', 'Sân cầu lông Eco - sân số 1') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100702', '00000000-0000-0000-0000-000000000207', 'Sân 2', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674976/badbook/alobo-seed/san-cau-long-eco.jpg', 'ACTIVE', 'Sân cầu lông Eco - sân số 2') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100703', '00000000-0000-0000-0000-000000000207', 'Sân 3', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674976/badbook/alobo-seed/san-cau-long-eco.jpg', 'ACTIVE', 'Sân cầu lông Eco - sân số 3') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100704', '00000000-0000-0000-0000-000000000207', 'Sân 4', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674976/badbook/alobo-seed/san-cau-long-eco.jpg', 'ACTIVE', 'Sân cầu lông Eco - sân số 4') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100705', '00000000-0000-0000-0000-000000000207', 'Sân 5', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674976/badbook/alobo-seed/san-cau-long-eco.jpg', 'ACTIVE', 'Sân cầu lông Eco - sân số 5') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100706', '00000000-0000-0000-0000-000000000207', 'Sân 6', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674976/badbook/alobo-seed/san-cau-long-eco.jpg', 'ACTIVE', 'Sân cầu lông Eco - sân số 6') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100707', '00000000-0000-0000-0000-000000000207', 'Sân 7', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674976/badbook/alobo-seed/san-cau-long-eco.jpg', 'ACTIVE', 'Sân cầu lông Eco - sân số 7') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100708', '00000000-0000-0000-0000-000000000207', 'Sân 8', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674976/badbook/alobo-seed/san-cau-long-eco.jpg', 'ACTIVE', 'Sân cầu lông Eco - sân số 8') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100709', '00000000-0000-0000-0000-000000000207', 'Sân 9', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674976/badbook/alobo-seed/san-cau-long-eco.jpg', 'ACTIVE', 'Sân cầu lông Eco - sân số 9') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100710', '00000000-0000-0000-0000-000000000207', 'Sân 10', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674976/badbook/alobo-seed/san-cau-long-eco.jpg', 'ACTIVE', 'Sân cầu lông Eco - sân số 10') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100711', '00000000-0000-0000-0000-000000000207', 'Sân 11', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674976/badbook/alobo-seed/san-cau-long-eco.jpg', 'ACTIVE', 'Sân cầu lông Eco - sân số 11') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100712', '00000000-0000-0000-0000-000000000207', 'Sân 12', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674976/badbook/alobo-seed/san-cau-long-eco.jpg', 'ACTIVE', 'Sân cầu lông Eco - sân số 12') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100713', '00000000-0000-0000-0000-000000000207', 'Sân 13', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674976/badbook/alobo-seed/san-cau-long-eco.jpg', 'ACTIVE', 'Sân cầu lông Eco - sân số 13') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100714', '00000000-0000-0000-0000-000000000207', 'Sân 14', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674976/badbook/alobo-seed/san-cau-long-eco.jpg', 'ACTIVE', 'Sân cầu lông Eco - sân số 14') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100715', '00000000-0000-0000-0000-000000000207', 'Sân 15', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674976/badbook/alobo-seed/san-cau-long-eco.jpg', 'ACTIVE', 'Sân cầu lông Eco - sân số 15') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100716', '00000000-0000-0000-0000-000000000207', 'Sân 16', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674976/badbook/alobo-seed/san-cau-long-eco.jpg', 'ACTIVE', 'Sân cầu lông Eco - sân số 16') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100717', '00000000-0000-0000-0000-000000000207', 'Sân 17', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674976/badbook/alobo-seed/san-cau-long-eco.jpg', 'ACTIVE', 'Sân cầu lông Eco - sân số 17') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;

-- 08. Sân cầu lông ECOSPORT
-- Sources: https://www.alobo.vn/dia-chi-thue-san-cau-long-tren-app-alobo/
-- Booking URL: not publicly exposed
INSERT INTO users (id, name, email, password, phone, image_id, created_at, is_deleted) VALUES
  ('00000000-0000-0000-0000-000000000108', 'Quản lý Sân cầu lông ECOSPORT', 'seed.alobo.ecosport-govap@badbook.local', '$2a$10$.Kg4C4UFpowiqgkHbCYhPuh3hKZkgFApkQ7H4kJKGpmIKSYLndJI6', '0909918012', NULL, CURRENT_TIMESTAMP, FALSE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  password = EXCLUDED.password,
  phone = EXCLUDED.phone,
  is_deleted = FALSE;
INSERT INTO user_roles (user_id, role_name) VALUES ('00000000-0000-0000-0000-000000000108', 'VENUE_MANAGER') ON CONFLICT DO NOTHING;
INSERT INTO venues (id, owner_id, name, address, latitude, longitude, description, banner_ids, license_id, status, open_time, close_time, platform_fee_rate, bank_name, bank_number, bank_account_name, created_at) VALUES
  ('00000000-0000-0000-0000-000000000208', '00000000-0000-0000-0000-000000000108', 'Sân cầu lông ECOSPORT', '273 Phạm Văn Chiêu, Phường 14, Gò Vấp, TP.HCM', 10.84120000, 106.65710000, 'ECOSPORT có 10 sân phủ thảm, trần cao khoảng 9m, hệ đèn chống chói và quầy nước cùng dịch vụ cho thuê vợt.', 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674981/badbook/alobo-seed/san-cau-long-ecosport.png', 'ALOBO-SEED-ECOSPORT', 'ACTIVE', '05:00', '23:00', 0.1000, 'Vietcombank', '190000000008', 'QUẢN LÝ SÂN CẦU LÔNG ECOSPORT', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET
  owner_id = EXCLUDED.owner_id,
  name = EXCLUDED.name,
  address = EXCLUDED.address,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude,
  description = EXCLUDED.description,
  banner_ids = EXCLUDED.banner_ids,
  license_id = EXCLUDED.license_id,
  status = EXCLUDED.status,
  open_time = EXCLUDED.open_time,
  close_time = EXCLUDED.close_time,
  platform_fee_rate = EXCLUDED.platform_fee_rate,
  bank_name = EXCLUDED.bank_name,
  bank_number = EXCLUDED.bank_number,
  bank_account_name = EXCLUDED.bank_account_name;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020081', '00000000-0000-0000-0000-000000000208', 'MONDAY', '05:00', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020082', '00000000-0000-0000-0000-000000000208', 'TUESDAY', '05:00', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020083', '00000000-0000-0000-0000-000000000208', 'WEDNESDAY', '05:00', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020084', '00000000-0000-0000-0000-000000000208', 'THURSDAY', '05:00', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020085', '00000000-0000-0000-0000-000000000208', 'FRIDAY', '05:00', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020086', '00000000-0000-0000-0000-000000000208', 'SATURDAY', '05:00', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020087', '00000000-0000-0000-0000-000000000208', 'SUNDAY', '05:00', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100801', '00000000-0000-0000-0000-000000000208', 'Sân 1', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674981/badbook/alobo-seed/san-cau-long-ecosport.png', 'ACTIVE', 'Sân cầu lông ECOSPORT - sân số 1') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100802', '00000000-0000-0000-0000-000000000208', 'Sân 2', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674981/badbook/alobo-seed/san-cau-long-ecosport.png', 'ACTIVE', 'Sân cầu lông ECOSPORT - sân số 2') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100803', '00000000-0000-0000-0000-000000000208', 'Sân 3', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674981/badbook/alobo-seed/san-cau-long-ecosport.png', 'ACTIVE', 'Sân cầu lông ECOSPORT - sân số 3') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100804', '00000000-0000-0000-0000-000000000208', 'Sân 4', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674981/badbook/alobo-seed/san-cau-long-ecosport.png', 'ACTIVE', 'Sân cầu lông ECOSPORT - sân số 4') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100805', '00000000-0000-0000-0000-000000000208', 'Sân 5', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674981/badbook/alobo-seed/san-cau-long-ecosport.png', 'ACTIVE', 'Sân cầu lông ECOSPORT - sân số 5') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100806', '00000000-0000-0000-0000-000000000208', 'Sân 6', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674981/badbook/alobo-seed/san-cau-long-ecosport.png', 'ACTIVE', 'Sân cầu lông ECOSPORT - sân số 6') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100807', '00000000-0000-0000-0000-000000000208', 'Sân 7', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674981/badbook/alobo-seed/san-cau-long-ecosport.png', 'ACTIVE', 'Sân cầu lông ECOSPORT - sân số 7') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100808', '00000000-0000-0000-0000-000000000208', 'Sân 8', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674981/badbook/alobo-seed/san-cau-long-ecosport.png', 'ACTIVE', 'Sân cầu lông ECOSPORT - sân số 8') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100809', '00000000-0000-0000-0000-000000000208', 'Sân 9', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674981/badbook/alobo-seed/san-cau-long-ecosport.png', 'ACTIVE', 'Sân cầu lông ECOSPORT - sân số 9') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100810', '00000000-0000-0000-0000-000000000208', 'Sân 10', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674981/badbook/alobo-seed/san-cau-long-ecosport.png', 'ACTIVE', 'Sân cầu lông ECOSPORT - sân số 10') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;

-- 09. CLB Cầu lông Hoàng Văn Thụ
-- Sources: https://www.alobo.vn/dia-chi-thue-san-cau-long-tren-app-alobo/ | https://www.alobo.vn/cach-dat-san-cau-long-online-vo-cung-don-gian-qua-ung-dung-alobo/
-- Booking URL: not publicly exposed
INSERT INTO users (id, name, email, password, phone, image_id, created_at, is_deleted) VALUES
  ('00000000-0000-0000-0000-000000000109', 'Quản lý CLB Cầu lông Hoàng Văn Thụ', 'seed.alobo.hoang-van-thu@badbook.local', '$2a$10$.Kg4C4UFpowiqgkHbCYhPuh3hKZkgFApkQ7H4kJKGpmIKSYLndJI6', '0564202202', NULL, CURRENT_TIMESTAMP, FALSE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  password = EXCLUDED.password,
  phone = EXCLUDED.phone,
  is_deleted = FALSE;
INSERT INTO user_roles (user_id, role_name) VALUES ('00000000-0000-0000-0000-000000000109', 'VENUE_MANAGER') ON CONFLICT DO NOTHING;
INSERT INTO venues (id, owner_id, name, address, latitude, longitude, description, banner_ids, license_id, status, open_time, close_time, platform_fee_rate, bank_name, bank_number, bank_account_name, created_at) VALUES
  ('00000000-0000-0000-0000-000000000209', '00000000-0000-0000-0000-000000000109', 'CLB Cầu lông Hoàng Văn Thụ', '202B Hoàng Văn Thụ, Phường 9, Phú Nhuận, TP.HCM', 10.80060000, 106.67200000, 'CLB Hoàng Văn Thụ có 15 sân, hệ thống đèn hiện đại, bề mặt sân chất lượng cao và bãi giữ xe rộng.', 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674985/badbook/alobo-seed/clb-cau-long-hoang-van-thu.png', 'ALOBO-SEED-HOANGVANTHU', 'ACTIVE', '05:00', '23:30', 0.1000, 'Vietcombank', '190000000009', 'QUẢN LÝ CLB CẦU LÔNG HOÀNG VĂN THỤ', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET
  owner_id = EXCLUDED.owner_id,
  name = EXCLUDED.name,
  address = EXCLUDED.address,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude,
  description = EXCLUDED.description,
  banner_ids = EXCLUDED.banner_ids,
  license_id = EXCLUDED.license_id,
  status = EXCLUDED.status,
  open_time = EXCLUDED.open_time,
  close_time = EXCLUDED.close_time,
  platform_fee_rate = EXCLUDED.platform_fee_rate,
  bank_name = EXCLUDED.bank_name,
  bank_number = EXCLUDED.bank_number,
  bank_account_name = EXCLUDED.bank_account_name;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020091', '00000000-0000-0000-0000-000000000209', 'MONDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020092', '00000000-0000-0000-0000-000000000209', 'TUESDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020093', '00000000-0000-0000-0000-000000000209', 'WEDNESDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020094', '00000000-0000-0000-0000-000000000209', 'THURSDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020095', '00000000-0000-0000-0000-000000000209', 'FRIDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020096', '00000000-0000-0000-0000-000000000209', 'SATURDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020097', '00000000-0000-0000-0000-000000000209', 'SUNDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100901', '00000000-0000-0000-0000-000000000209', 'Sân 1', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674985/badbook/alobo-seed/clb-cau-long-hoang-van-thu.png', 'ACTIVE', 'CLB Cầu lông Hoàng Văn Thụ - sân số 1') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100902', '00000000-0000-0000-0000-000000000209', 'Sân 2', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674985/badbook/alobo-seed/clb-cau-long-hoang-van-thu.png', 'ACTIVE', 'CLB Cầu lông Hoàng Văn Thụ - sân số 2') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100903', '00000000-0000-0000-0000-000000000209', 'Sân 3', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674985/badbook/alobo-seed/clb-cau-long-hoang-van-thu.png', 'ACTIVE', 'CLB Cầu lông Hoàng Văn Thụ - sân số 3') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100904', '00000000-0000-0000-0000-000000000209', 'Sân 4', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674985/badbook/alobo-seed/clb-cau-long-hoang-van-thu.png', 'ACTIVE', 'CLB Cầu lông Hoàng Văn Thụ - sân số 4') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100905', '00000000-0000-0000-0000-000000000209', 'Sân 5', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674985/badbook/alobo-seed/clb-cau-long-hoang-van-thu.png', 'ACTIVE', 'CLB Cầu lông Hoàng Văn Thụ - sân số 5') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100906', '00000000-0000-0000-0000-000000000209', 'Sân 6', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674985/badbook/alobo-seed/clb-cau-long-hoang-van-thu.png', 'ACTIVE', 'CLB Cầu lông Hoàng Văn Thụ - sân số 6') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100907', '00000000-0000-0000-0000-000000000209', 'Sân 7', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674985/badbook/alobo-seed/clb-cau-long-hoang-van-thu.png', 'ACTIVE', 'CLB Cầu lông Hoàng Văn Thụ - sân số 7') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100908', '00000000-0000-0000-0000-000000000209', 'Sân 8', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674985/badbook/alobo-seed/clb-cau-long-hoang-van-thu.png', 'ACTIVE', 'CLB Cầu lông Hoàng Văn Thụ - sân số 8') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100909', '00000000-0000-0000-0000-000000000209', 'Sân 9', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674985/badbook/alobo-seed/clb-cau-long-hoang-van-thu.png', 'ACTIVE', 'CLB Cầu lông Hoàng Văn Thụ - sân số 9') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100910', '00000000-0000-0000-0000-000000000209', 'Sân 10', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674985/badbook/alobo-seed/clb-cau-long-hoang-van-thu.png', 'ACTIVE', 'CLB Cầu lông Hoàng Văn Thụ - sân số 10') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100911', '00000000-0000-0000-0000-000000000209', 'Sân 11', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674985/badbook/alobo-seed/clb-cau-long-hoang-van-thu.png', 'ACTIVE', 'CLB Cầu lông Hoàng Văn Thụ - sân số 11') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100912', '00000000-0000-0000-0000-000000000209', 'Sân 12', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674985/badbook/alobo-seed/clb-cau-long-hoang-van-thu.png', 'ACTIVE', 'CLB Cầu lông Hoàng Văn Thụ - sân số 12') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100913', '00000000-0000-0000-0000-000000000209', 'Sân 13', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674985/badbook/alobo-seed/clb-cau-long-hoang-van-thu.png', 'ACTIVE', 'CLB Cầu lông Hoàng Văn Thụ - sân số 13') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100914', '00000000-0000-0000-0000-000000000209', 'Sân 14', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674985/badbook/alobo-seed/clb-cau-long-hoang-van-thu.png', 'ACTIVE', 'CLB Cầu lông Hoàng Văn Thụ - sân số 14') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000100915', '00000000-0000-0000-0000-000000000209', 'Sân 15', 'STANDARD', 120000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674985/badbook/alobo-seed/clb-cau-long-hoang-van-thu.png', 'ACTIVE', 'CLB Cầu lông Hoàng Văn Thụ - sân số 15') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;

-- 10. Sân cầu lông Hồng Châu
-- Sources: https://www.alobo.vn/dia-chi-thue-san-cau-long-tren-app-alobo/ | https://caulonghongchau.com/dat-san
-- Booking URL: https://datlich.alobo.vn/san/sport_hong_chau
INSERT INTO users (id, name, email, password, phone, image_id, created_at, is_deleted) VALUES
  ('00000000-0000-0000-0000-000000000110', 'Quản lý Sân cầu lông Hồng Châu', 'seed.alobo.hong-chau@badbook.local', '$2a$10$.Kg4C4UFpowiqgkHbCYhPuh3hKZkgFApkQ7H4kJKGpmIKSYLndJI6', '0348869370', NULL, CURRENT_TIMESTAMP, FALSE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  password = EXCLUDED.password,
  phone = EXCLUDED.phone,
  is_deleted = FALSE;
INSERT INTO user_roles (user_id, role_name) VALUES ('00000000-0000-0000-0000-000000000110', 'VENUE_MANAGER') ON CONFLICT DO NOTHING;
INSERT INTO venues (id, owner_id, name, address, latitude, longitude, description, banner_ids, license_id, status, open_time, close_time, platform_fee_rate, bank_name, bank_number, bank_account_name, created_at) VALUES
  ('00000000-0000-0000-0000-000000000210', '00000000-0000-0000-0000-000000000110', 'Sân cầu lông Hồng Châu', '1387 Bến Bình Đông, Phường Phú Định, TP.HCM', 10.74100000, 106.63750000, 'Hồng Châu có 6 sân đạt chuẩn, ghế chờ rộng rãi, khu giãn cơ và dịch vụ thuê vợt, nước uống cho người chơi.', 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674986/badbook/alobo-seed/san-cau-long-hong-chau.jpg', 'ALOBO-SEED-HONGCHAU', 'ACTIVE', '00:00', '23:30', 0.1000, 'Vietcombank', '190000000010', 'QUẢN LÝ SÂN CẦU LÔNG HỒNG CHÂU', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET
  owner_id = EXCLUDED.owner_id,
  name = EXCLUDED.name,
  address = EXCLUDED.address,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude,
  description = EXCLUDED.description,
  banner_ids = EXCLUDED.banner_ids,
  license_id = EXCLUDED.license_id,
  status = EXCLUDED.status,
  open_time = EXCLUDED.open_time,
  close_time = EXCLUDED.close_time,
  platform_fee_rate = EXCLUDED.platform_fee_rate,
  bank_name = EXCLUDED.bank_name,
  bank_number = EXCLUDED.bank_number,
  bank_account_name = EXCLUDED.bank_account_name;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020101', '00000000-0000-0000-0000-000000000210', 'MONDAY', '00:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020102', '00000000-0000-0000-0000-000000000210', 'TUESDAY', '00:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020103', '00000000-0000-0000-0000-000000000210', 'WEDNESDAY', '00:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020104', '00000000-0000-0000-0000-000000000210', 'THURSDAY', '00:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020105', '00000000-0000-0000-0000-000000000210', 'FRIDAY', '00:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020106', '00000000-0000-0000-0000-000000000210', 'SATURDAY', '00:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020107', '00000000-0000-0000-0000-000000000210', 'SUNDAY', '00:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101001', '00000000-0000-0000-0000-000000000210', 'Sân 1', 'STANDARD', 70000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674986/badbook/alobo-seed/san-cau-long-hong-chau.jpg', 'ACTIVE', 'Sân cầu lông Hồng Châu - sân số 1') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101002', '00000000-0000-0000-0000-000000000210', 'Sân 2', 'STANDARD', 70000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674986/badbook/alobo-seed/san-cau-long-hong-chau.jpg', 'ACTIVE', 'Sân cầu lông Hồng Châu - sân số 2') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101003', '00000000-0000-0000-0000-000000000210', 'Sân 3', 'STANDARD', 70000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674986/badbook/alobo-seed/san-cau-long-hong-chau.jpg', 'ACTIVE', 'Sân cầu lông Hồng Châu - sân số 3') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101004', '00000000-0000-0000-0000-000000000210', 'Sân 4', 'STANDARD', 70000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674986/badbook/alobo-seed/san-cau-long-hong-chau.jpg', 'ACTIVE', 'Sân cầu lông Hồng Châu - sân số 4') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101005', '00000000-0000-0000-0000-000000000210', 'Sân 5', 'STANDARD', 70000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674986/badbook/alobo-seed/san-cau-long-hong-chau.jpg', 'ACTIVE', 'Sân cầu lông Hồng Châu - sân số 5') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101006', '00000000-0000-0000-0000-000000000210', 'Sân 6', 'STANDARD', 70000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674986/badbook/alobo-seed/san-cau-long-hong-chau.jpg', 'ACTIVE', 'Sân cầu lông Hồng Châu - sân số 6') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;

-- 11. CLB Cầu lông Trường Chinh 909
-- Sources: https://www.alobo.vn/dia-chi-thue-san-cau-long-tren-app-alobo/ | https://www.alobo.vn/cach-dat-san-cau-long-online-vo-cung-don-gian-qua-ung-dung-alobo/
-- Booking URL: not publicly exposed
INSERT INTO users (id, name, email, password, phone, image_id, created_at, is_deleted) VALUES
  ('00000000-0000-0000-0000-000000000111', 'Quản lý CLB Cầu lông Trường Chinh 909', 'seed.alobo.truong-chinh-909@badbook.local', '$2a$10$.Kg4C4UFpowiqgkHbCYhPuh3hKZkgFApkQ7H4kJKGpmIKSYLndJI6', '0903933533', NULL, CURRENT_TIMESTAMP, FALSE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  password = EXCLUDED.password,
  phone = EXCLUDED.phone,
  is_deleted = FALSE;
INSERT INTO user_roles (user_id, role_name) VALUES ('00000000-0000-0000-0000-000000000111', 'VENUE_MANAGER') ON CONFLICT DO NOTHING;
INSERT INTO venues (id, owner_id, name, address, latitude, longitude, description, banner_ids, license_id, status, open_time, close_time, platform_fee_rate, bank_name, bank_number, bank_account_name, created_at) VALUES
  ('00000000-0000-0000-0000-000000000211', '00000000-0000-0000-0000-000000000111', 'CLB Cầu lông Trường Chinh 909', '909/6 Trường Chinh, phường Tây Thạnh, Tân Phú, TP.HCM', 10.80490000, 106.63560000, 'Trường Chinh 909 có 10 sân thảm PVC đạt chuẩn, phù hợp cả tập luyện lẫn thi đấu phong trào.', 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674989/badbook/alobo-seed/clb-cau-long-truong-chinh-909.png', 'ALOBO-SEED-TC909', 'ACTIVE', '05:00', '23:30', 0.1000, 'Vietcombank', '190000000011', 'QUẢN LÝ CLB CẦU LÔNG TRƯỜNG CHINH 909', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET
  owner_id = EXCLUDED.owner_id,
  name = EXCLUDED.name,
  address = EXCLUDED.address,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude,
  description = EXCLUDED.description,
  banner_ids = EXCLUDED.banner_ids,
  license_id = EXCLUDED.license_id,
  status = EXCLUDED.status,
  open_time = EXCLUDED.open_time,
  close_time = EXCLUDED.close_time,
  platform_fee_rate = EXCLUDED.platform_fee_rate,
  bank_name = EXCLUDED.bank_name,
  bank_number = EXCLUDED.bank_number,
  bank_account_name = EXCLUDED.bank_account_name;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020111', '00000000-0000-0000-0000-000000000211', 'MONDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020112', '00000000-0000-0000-0000-000000000211', 'TUESDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020113', '00000000-0000-0000-0000-000000000211', 'WEDNESDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020114', '00000000-0000-0000-0000-000000000211', 'THURSDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020115', '00000000-0000-0000-0000-000000000211', 'FRIDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020116', '00000000-0000-0000-0000-000000000211', 'SATURDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020117', '00000000-0000-0000-0000-000000000211', 'SUNDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101101', '00000000-0000-0000-0000-000000000211', 'Sân 1', 'STANDARD', 70000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674989/badbook/alobo-seed/clb-cau-long-truong-chinh-909.png', 'ACTIVE', 'CLB Cầu lông Trường Chinh 909 - sân số 1') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101102', '00000000-0000-0000-0000-000000000211', 'Sân 2', 'STANDARD', 70000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674989/badbook/alobo-seed/clb-cau-long-truong-chinh-909.png', 'ACTIVE', 'CLB Cầu lông Trường Chinh 909 - sân số 2') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101103', '00000000-0000-0000-0000-000000000211', 'Sân 3', 'STANDARD', 70000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674989/badbook/alobo-seed/clb-cau-long-truong-chinh-909.png', 'ACTIVE', 'CLB Cầu lông Trường Chinh 909 - sân số 3') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101104', '00000000-0000-0000-0000-000000000211', 'Sân 4', 'STANDARD', 70000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674989/badbook/alobo-seed/clb-cau-long-truong-chinh-909.png', 'ACTIVE', 'CLB Cầu lông Trường Chinh 909 - sân số 4') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101105', '00000000-0000-0000-0000-000000000211', 'Sân 5', 'STANDARD', 70000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674989/badbook/alobo-seed/clb-cau-long-truong-chinh-909.png', 'ACTIVE', 'CLB Cầu lông Trường Chinh 909 - sân số 5') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101106', '00000000-0000-0000-0000-000000000211', 'Sân 6', 'STANDARD', 70000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674989/badbook/alobo-seed/clb-cau-long-truong-chinh-909.png', 'ACTIVE', 'CLB Cầu lông Trường Chinh 909 - sân số 6') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101107', '00000000-0000-0000-0000-000000000211', 'Sân 7', 'STANDARD', 70000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674989/badbook/alobo-seed/clb-cau-long-truong-chinh-909.png', 'ACTIVE', 'CLB Cầu lông Trường Chinh 909 - sân số 7') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101108', '00000000-0000-0000-0000-000000000211', 'Sân 8', 'STANDARD', 70000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674989/badbook/alobo-seed/clb-cau-long-truong-chinh-909.png', 'ACTIVE', 'CLB Cầu lông Trường Chinh 909 - sân số 8') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101109', '00000000-0000-0000-0000-000000000211', 'Sân 9', 'STANDARD', 70000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674989/badbook/alobo-seed/clb-cau-long-truong-chinh-909.png', 'ACTIVE', 'CLB Cầu lông Trường Chinh 909 - sân số 9') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101110', '00000000-0000-0000-0000-000000000211', 'Sân 10', 'STANDARD', 70000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674989/badbook/alobo-seed/clb-cau-long-truong-chinh-909.png', 'ACTIVE', 'CLB Cầu lông Trường Chinh 909 - sân số 10') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;

-- 12. CLB Cầu lông Gia Hân
-- Sources: https://www.alobo.vn/dia-chi-thue-san-cau-long-tren-app-alobo/
-- Booking URL: not publicly exposed
INSERT INTO users (id, name, email, password, phone, image_id, created_at, is_deleted) VALUES
  ('00000000-0000-0000-0000-000000000112', 'Quản lý CLB Cầu lông Gia Hân', 'seed.alobo.gia-han@badbook.local', '$2a$10$.Kg4C4UFpowiqgkHbCYhPuh3hKZkgFApkQ7H4kJKGpmIKSYLndJI6', '0797897799', NULL, CURRENT_TIMESTAMP, FALSE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  password = EXCLUDED.password,
  phone = EXCLUDED.phone,
  is_deleted = FALSE;
INSERT INTO user_roles (user_id, role_name) VALUES ('00000000-0000-0000-0000-000000000112', 'VENUE_MANAGER') ON CONFLICT DO NOTHING;
INSERT INTO venues (id, owner_id, name, address, latitude, longitude, description, banner_ids, license_id, status, open_time, close_time, platform_fee_rate, bank_name, bank_number, bank_account_name, created_at) VALUES
  ('00000000-0000-0000-0000-000000000212', '00000000-0000-0000-0000-000000000112', 'CLB Cầu lông Gia Hân', '299 Phan Văn Hới, phường Tân Thới Nhất, Quận 12, TP.HCM', 10.85620000, 106.62530000, 'Gia Hân có 8 sân thoáng, thảm chuẩn, chỗ ngồi rộng, phòng tắm sạch và nhiều tiện ích đi kèm.', 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674994/badbook/alobo-seed/clb-cau-long-gia-han.png', 'ALOBO-SEED-GIAHAN', 'ACTIVE', '05:00', '23:00', 0.1000, 'Vietcombank', '190000000012', 'QUẢN LÝ CLB CẦU LÔNG GIA HÂN', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET
  owner_id = EXCLUDED.owner_id,
  name = EXCLUDED.name,
  address = EXCLUDED.address,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude,
  description = EXCLUDED.description,
  banner_ids = EXCLUDED.banner_ids,
  license_id = EXCLUDED.license_id,
  status = EXCLUDED.status,
  open_time = EXCLUDED.open_time,
  close_time = EXCLUDED.close_time,
  platform_fee_rate = EXCLUDED.platform_fee_rate,
  bank_name = EXCLUDED.bank_name,
  bank_number = EXCLUDED.bank_number,
  bank_account_name = EXCLUDED.bank_account_name;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020121', '00000000-0000-0000-0000-000000000212', 'MONDAY', '05:00', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020122', '00000000-0000-0000-0000-000000000212', 'TUESDAY', '05:00', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020123', '00000000-0000-0000-0000-000000000212', 'WEDNESDAY', '05:00', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020124', '00000000-0000-0000-0000-000000000212', 'THURSDAY', '05:00', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020125', '00000000-0000-0000-0000-000000000212', 'FRIDAY', '05:00', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020126', '00000000-0000-0000-0000-000000000212', 'SATURDAY', '05:00', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020127', '00000000-0000-0000-0000-000000000212', 'SUNDAY', '05:00', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101201', '00000000-0000-0000-0000-000000000212', 'Sân 1', 'STANDARD', 80000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674994/badbook/alobo-seed/clb-cau-long-gia-han.png', 'ACTIVE', 'CLB Cầu lông Gia Hân - sân số 1') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101202', '00000000-0000-0000-0000-000000000212', 'Sân 2', 'STANDARD', 80000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674994/badbook/alobo-seed/clb-cau-long-gia-han.png', 'ACTIVE', 'CLB Cầu lông Gia Hân - sân số 2') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101203', '00000000-0000-0000-0000-000000000212', 'Sân 3', 'STANDARD', 80000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674994/badbook/alobo-seed/clb-cau-long-gia-han.png', 'ACTIVE', 'CLB Cầu lông Gia Hân - sân số 3') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101204', '00000000-0000-0000-0000-000000000212', 'Sân 4', 'STANDARD', 80000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674994/badbook/alobo-seed/clb-cau-long-gia-han.png', 'ACTIVE', 'CLB Cầu lông Gia Hân - sân số 4') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101205', '00000000-0000-0000-0000-000000000212', 'Sân 5', 'STANDARD', 80000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674994/badbook/alobo-seed/clb-cau-long-gia-han.png', 'ACTIVE', 'CLB Cầu lông Gia Hân - sân số 5') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101206', '00000000-0000-0000-0000-000000000212', 'Sân 6', 'STANDARD', 80000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674994/badbook/alobo-seed/clb-cau-long-gia-han.png', 'ACTIVE', 'CLB Cầu lông Gia Hân - sân số 6') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101207', '00000000-0000-0000-0000-000000000212', 'Sân 7', 'STANDARD', 80000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674994/badbook/alobo-seed/clb-cau-long-gia-han.png', 'ACTIVE', 'CLB Cầu lông Gia Hân - sân số 7') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101208', '00000000-0000-0000-0000-000000000212', 'Sân 8', 'STANDARD', 80000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780674994/badbook/alobo-seed/clb-cau-long-gia-han.png', 'ACTIVE', 'CLB Cầu lông Gia Hân - sân số 8') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;

-- 13. Sân cầu lông Sky Badminton
-- Sources: https://www.alobo.vn/dia-chi-thue-san-cau-long-tren-app-alobo/
-- Booking URL: not publicly exposed
INSERT INTO users (id, name, email, password, phone, image_id, created_at, is_deleted) VALUES
  ('00000000-0000-0000-0000-000000000113', 'Quản lý Sân cầu lông Sky Badminton', 'seed.alobo.sky-badminton@badbook.local', '$2a$10$.Kg4C4UFpowiqgkHbCYhPuh3hKZkgFApkQ7H4kJKGpmIKSYLndJI6', '0705886441', NULL, CURRENT_TIMESTAMP, FALSE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  password = EXCLUDED.password,
  phone = EXCLUDED.phone,
  is_deleted = FALSE;
INSERT INTO user_roles (user_id, role_name) VALUES ('00000000-0000-0000-0000-000000000113', 'VENUE_MANAGER') ON CONFLICT DO NOTHING;
INSERT INTO venues (id, owner_id, name, address, latitude, longitude, description, banner_ids, license_id, status, open_time, close_time, platform_fee_rate, bank_name, bank_number, bank_account_name, created_at) VALUES
  ('00000000-0000-0000-0000-000000000213', '00000000-0000-0000-0000-000000000113', 'Sân cầu lông Sky Badminton', '462/9 Nguyễn Xiển, phường Long Thạnh, TP. Thủ Đức, TP.HCM', 10.83450000, 106.81080000, 'Sky Badminton có 7 sân chính và 1 sân tập riêng, đèn đạt chuẩn và không gian rộng tại khu vực Thủ Đức.', 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675000/badbook/alobo-seed/san-cau-long-sky-badminton.png', 'ALOBO-SEED-SKY', 'ACTIVE', '05:30', '23:00', 0.1000, 'Vietcombank', '190000000013', 'QUẢN LÝ SÂN CẦU LÔNG SKY BADMINTON', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET
  owner_id = EXCLUDED.owner_id,
  name = EXCLUDED.name,
  address = EXCLUDED.address,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude,
  description = EXCLUDED.description,
  banner_ids = EXCLUDED.banner_ids,
  license_id = EXCLUDED.license_id,
  status = EXCLUDED.status,
  open_time = EXCLUDED.open_time,
  close_time = EXCLUDED.close_time,
  platform_fee_rate = EXCLUDED.platform_fee_rate,
  bank_name = EXCLUDED.bank_name,
  bank_number = EXCLUDED.bank_number,
  bank_account_name = EXCLUDED.bank_account_name;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020131', '00000000-0000-0000-0000-000000000213', 'MONDAY', '05:30', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020132', '00000000-0000-0000-0000-000000000213', 'TUESDAY', '05:30', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020133', '00000000-0000-0000-0000-000000000213', 'WEDNESDAY', '05:30', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020134', '00000000-0000-0000-0000-000000000213', 'THURSDAY', '05:30', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020135', '00000000-0000-0000-0000-000000000213', 'FRIDAY', '05:30', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020136', '00000000-0000-0000-0000-000000000213', 'SATURDAY', '05:30', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020137', '00000000-0000-0000-0000-000000000213', 'SUNDAY', '05:30', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101301', '00000000-0000-0000-0000-000000000213', 'Sân 1', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675000/badbook/alobo-seed/san-cau-long-sky-badminton.png', 'ACTIVE', 'Sân cầu lông Sky Badminton - sân số 1') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101302', '00000000-0000-0000-0000-000000000213', 'Sân 2', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675000/badbook/alobo-seed/san-cau-long-sky-badminton.png', 'ACTIVE', 'Sân cầu lông Sky Badminton - sân số 2') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101303', '00000000-0000-0000-0000-000000000213', 'Sân 3', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675000/badbook/alobo-seed/san-cau-long-sky-badminton.png', 'ACTIVE', 'Sân cầu lông Sky Badminton - sân số 3') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101304', '00000000-0000-0000-0000-000000000213', 'Sân 4', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675000/badbook/alobo-seed/san-cau-long-sky-badminton.png', 'ACTIVE', 'Sân cầu lông Sky Badminton - sân số 4') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101305', '00000000-0000-0000-0000-000000000213', 'Sân 5', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675000/badbook/alobo-seed/san-cau-long-sky-badminton.png', 'ACTIVE', 'Sân cầu lông Sky Badminton - sân số 5') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101306', '00000000-0000-0000-0000-000000000213', 'Sân 6', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675000/badbook/alobo-seed/san-cau-long-sky-badminton.png', 'ACTIVE', 'Sân cầu lông Sky Badminton - sân số 6') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101307', '00000000-0000-0000-0000-000000000213', 'Sân 7', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675000/badbook/alobo-seed/san-cau-long-sky-badminton.png', 'ACTIVE', 'Sân cầu lông Sky Badminton - sân số 7') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101308', '00000000-0000-0000-0000-000000000213', 'Sân 8', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675000/badbook/alobo-seed/san-cau-long-sky-badminton.png', 'ACTIVE', 'Sân cầu lông Sky Badminton - sân số 8') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;

-- 14. Sân cầu lông 68
-- Sources: https://www.alobo.vn/dia-chi-thue-san-cau-long-tren-app-alobo/
-- Booking URL: not publicly exposed
INSERT INTO users (id, name, email, password, phone, image_id, created_at, is_deleted) VALUES
  ('00000000-0000-0000-0000-000000000114', 'Quản lý Sân cầu lông 68', 'seed.alobo.san-68@badbook.local', '$2a$10$.Kg4C4UFpowiqgkHbCYhPuh3hKZkgFApkQ7H4kJKGpmIKSYLndJI6', '0372681913', NULL, CURRENT_TIMESTAMP, FALSE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  password = EXCLUDED.password,
  phone = EXCLUDED.phone,
  is_deleted = FALSE;
INSERT INTO user_roles (user_id, role_name) VALUES ('00000000-0000-0000-0000-000000000114', 'VENUE_MANAGER') ON CONFLICT DO NOTHING;
INSERT INTO venues (id, owner_id, name, address, latitude, longitude, description, banner_ids, license_id, status, open_time, close_time, platform_fee_rate, bank_name, bank_number, bank_account_name, created_at) VALUES
  ('00000000-0000-0000-0000-000000000214', '00000000-0000-0000-0000-000000000114', 'Sân cầu lông 68', '230A Kha Vạn Cân, phường Linh Trung, TP. Thủ Đức, TP.HCM', 10.87330000, 106.76390000, 'Sân 68 có 3 sân gần khu đại học, thảm PVC chống trơn và nhóm tiện ích cơ bản cho người chơi sinh viên.', 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675008/badbook/alobo-seed/san-cau-long-68.png', 'ALOBO-SEED-SAN68', 'ACTIVE', '05:00', '23:30', 0.1000, 'Vietcombank', '190000000014', 'QUẢN LÝ SÂN CẦU LÔNG 68', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET
  owner_id = EXCLUDED.owner_id,
  name = EXCLUDED.name,
  address = EXCLUDED.address,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude,
  description = EXCLUDED.description,
  banner_ids = EXCLUDED.banner_ids,
  license_id = EXCLUDED.license_id,
  status = EXCLUDED.status,
  open_time = EXCLUDED.open_time,
  close_time = EXCLUDED.close_time,
  platform_fee_rate = EXCLUDED.platform_fee_rate,
  bank_name = EXCLUDED.bank_name,
  bank_number = EXCLUDED.bank_number,
  bank_account_name = EXCLUDED.bank_account_name;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020141', '00000000-0000-0000-0000-000000000214', 'MONDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020142', '00000000-0000-0000-0000-000000000214', 'TUESDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020143', '00000000-0000-0000-0000-000000000214', 'WEDNESDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020144', '00000000-0000-0000-0000-000000000214', 'THURSDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020145', '00000000-0000-0000-0000-000000000214', 'FRIDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020146', '00000000-0000-0000-0000-000000000214', 'SATURDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020147', '00000000-0000-0000-0000-000000000214', 'SUNDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101401', '00000000-0000-0000-0000-000000000214', 'Sân 1', 'STANDARD', 60000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675008/badbook/alobo-seed/san-cau-long-68.png', 'ACTIVE', 'Sân cầu lông 68 - sân số 1') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101402', '00000000-0000-0000-0000-000000000214', 'Sân 2', 'STANDARD', 60000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675008/badbook/alobo-seed/san-cau-long-68.png', 'ACTIVE', 'Sân cầu lông 68 - sân số 2') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101403', '00000000-0000-0000-0000-000000000214', 'Sân 3', 'STANDARD', 60000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675008/badbook/alobo-seed/san-cau-long-68.png', 'ACTIVE', 'Sân cầu lông 68 - sân số 3') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;

-- 15. CLB Cầu lông Hòa Bình
-- Sources: https://www.alobo.vn/dia-chi-thue-san-cau-long-tren-app-alobo/ | https://www.localgymsandfitness.com/VN/Ho-Chi-Minh-City/306174855918071/Kho-S%E1%BB%89-C%E1%BA%A7u-L%C3%B4ng-To%C3%A0n-Qu%E1%BB%91c---The-B-Badminton-zalo-hotline%3A-0909.630.316 | https://www.alobo.vn/cach-dat-san-cau-long-online-vo-cung-don-gian-qua-ung-dung-alobo/
-- Booking URL: https://datlich.alobo.vn/san/sport_hoa_binh_badminton_arena_cn1
INSERT INTO users (id, name, email, password, phone, image_id, created_at, is_deleted) VALUES
  ('00000000-0000-0000-0000-000000000115', 'Quản lý CLB Cầu lông Hòa Bình', 'seed.alobo.hoa-binh@badbook.local', '$2a$10$.Kg4C4UFpowiqgkHbCYhPuh3hKZkgFApkQ7H4kJKGpmIKSYLndJI6', '0909630316', NULL, CURRENT_TIMESTAMP, FALSE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  password = EXCLUDED.password,
  phone = EXCLUDED.phone,
  is_deleted = FALSE;
INSERT INTO user_roles (user_id, role_name) VALUES ('00000000-0000-0000-0000-000000000115', 'VENUE_MANAGER') ON CONFLICT DO NOTHING;
INSERT INTO venues (id, owner_id, name, address, latitude, longitude, description, banner_ids, license_id, status, open_time, close_time, platform_fee_rate, bank_name, bank_number, bank_account_name, created_at) VALUES
  ('00000000-0000-0000-0000-000000000215', '00000000-0000-0000-0000-000000000115', 'CLB Cầu lông Hòa Bình', '316 Hòa Bình, phường Hiệp Tân, Tân Phú, TP.HCM', 10.76880000, 106.63170000, 'Hòa Bình có 7 sân nằm ngang, trần cao, bãi giữ xe rộng, quầy nước và khu chờ thoải mái cho nhóm chơi đông.', 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675012/badbook/alobo-seed/clb-cau-long-hoa-binh.png', 'ALOBO-SEED-HOABINH', 'ACTIVE', '00:00', '23:30', 0.1000, 'Vietcombank', '190000000015', 'QUẢN LÝ CLB CẦU LÔNG HÒA BÌNH', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET
  owner_id = EXCLUDED.owner_id,
  name = EXCLUDED.name,
  address = EXCLUDED.address,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude,
  description = EXCLUDED.description,
  banner_ids = EXCLUDED.banner_ids,
  license_id = EXCLUDED.license_id,
  status = EXCLUDED.status,
  open_time = EXCLUDED.open_time,
  close_time = EXCLUDED.close_time,
  platform_fee_rate = EXCLUDED.platform_fee_rate,
  bank_name = EXCLUDED.bank_name,
  bank_number = EXCLUDED.bank_number,
  bank_account_name = EXCLUDED.bank_account_name;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020151', '00000000-0000-0000-0000-000000000215', 'MONDAY', '00:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020152', '00000000-0000-0000-0000-000000000215', 'TUESDAY', '00:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020153', '00000000-0000-0000-0000-000000000215', 'WEDNESDAY', '00:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020154', '00000000-0000-0000-0000-000000000215', 'THURSDAY', '00:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020155', '00000000-0000-0000-0000-000000000215', 'FRIDAY', '00:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020156', '00000000-0000-0000-0000-000000000215', 'SATURDAY', '00:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020157', '00000000-0000-0000-0000-000000000215', 'SUNDAY', '00:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101501', '00000000-0000-0000-0000-000000000215', 'Sân 1', 'STANDARD', 80000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675012/badbook/alobo-seed/clb-cau-long-hoa-binh.png', 'ACTIVE', 'CLB Cầu lông Hòa Bình - sân số 1') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101502', '00000000-0000-0000-0000-000000000215', 'Sân 2', 'STANDARD', 80000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675012/badbook/alobo-seed/clb-cau-long-hoa-binh.png', 'ACTIVE', 'CLB Cầu lông Hòa Bình - sân số 2') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101503', '00000000-0000-0000-0000-000000000215', 'Sân 3', 'STANDARD', 80000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675012/badbook/alobo-seed/clb-cau-long-hoa-binh.png', 'ACTIVE', 'CLB Cầu lông Hòa Bình - sân số 3') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101504', '00000000-0000-0000-0000-000000000215', 'Sân 4', 'STANDARD', 80000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675012/badbook/alobo-seed/clb-cau-long-hoa-binh.png', 'ACTIVE', 'CLB Cầu lông Hòa Bình - sân số 4') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101505', '00000000-0000-0000-0000-000000000215', 'Sân 5', 'STANDARD', 80000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675012/badbook/alobo-seed/clb-cau-long-hoa-binh.png', 'ACTIVE', 'CLB Cầu lông Hòa Bình - sân số 5') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101506', '00000000-0000-0000-0000-000000000215', 'Sân 6', 'STANDARD', 80000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675012/badbook/alobo-seed/clb-cau-long-hoa-binh.png', 'ACTIVE', 'CLB Cầu lông Hòa Bình - sân số 6') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101507', '00000000-0000-0000-0000-000000000215', 'Sân 7', 'STANDARD', 80000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675012/badbook/alobo-seed/clb-cau-long-hoa-binh.png', 'ACTIVE', 'CLB Cầu lông Hòa Bình - sân số 7') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;

-- 16. HAAN Badminton Club
-- Sources: https://www.alobo.vn/dia-chi-thue-san-cau-long-tren-app-alobo/ | https://www.sieuthicaulong.vn/san-cau-long/ho-chi-minh/san-cau-long-haan-badminton-club-binh-tan-hcm
-- Booking URL: not publicly exposed
INSERT INTO users (id, name, email, password, phone, image_id, created_at, is_deleted) VALUES
  ('00000000-0000-0000-0000-000000000116', 'Quản lý HAAN Badminton Club', 'seed.alobo.haan-badminton@badbook.local', '$2a$10$.Kg4C4UFpowiqgkHbCYhPuh3hKZkgFApkQ7H4kJKGpmIKSYLndJI6', '0937240692', NULL, CURRENT_TIMESTAMP, FALSE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  password = EXCLUDED.password,
  phone = EXCLUDED.phone,
  is_deleted = FALSE;
INSERT INTO user_roles (user_id, role_name) VALUES ('00000000-0000-0000-0000-000000000116', 'VENUE_MANAGER') ON CONFLICT DO NOTHING;
INSERT INTO venues (id, owner_id, name, address, latitude, longitude, description, banner_ids, license_id, status, open_time, close_time, platform_fee_rate, bank_name, bank_number, bank_account_name, created_at) VALUES
  ('00000000-0000-0000-0000-000000000216', '00000000-0000-0000-0000-000000000116', 'HAAN Badminton Club', '31A Đường số 4, khu phố 17, Bình Hưng Hòa, Bình Tân, TP.HCM', 10.78560000, 106.60860000, 'HAAN Badminton Club có mặt sàn cao su cao cấp, hệ thống thông gió tốt và 3 sân phù hợp chơi phong trào lẫn luyện tập.', 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675017/badbook/alobo-seed/haan-badminton-club.png', 'ALOBO-SEED-HAAN', 'ACTIVE', '05:00', '23:00', 0.1000, 'Vietcombank', '190000000016', 'QUẢN LÝ HAAN BADMINTON CLUB', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET
  owner_id = EXCLUDED.owner_id,
  name = EXCLUDED.name,
  address = EXCLUDED.address,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude,
  description = EXCLUDED.description,
  banner_ids = EXCLUDED.banner_ids,
  license_id = EXCLUDED.license_id,
  status = EXCLUDED.status,
  open_time = EXCLUDED.open_time,
  close_time = EXCLUDED.close_time,
  platform_fee_rate = EXCLUDED.platform_fee_rate,
  bank_name = EXCLUDED.bank_name,
  bank_number = EXCLUDED.bank_number,
  bank_account_name = EXCLUDED.bank_account_name;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020161', '00000000-0000-0000-0000-000000000216', 'MONDAY', '05:00', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020162', '00000000-0000-0000-0000-000000000216', 'TUESDAY', '05:00', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020163', '00000000-0000-0000-0000-000000000216', 'WEDNESDAY', '05:00', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020164', '00000000-0000-0000-0000-000000000216', 'THURSDAY', '05:00', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020165', '00000000-0000-0000-0000-000000000216', 'FRIDAY', '05:00', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020166', '00000000-0000-0000-0000-000000000216', 'SATURDAY', '05:00', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020167', '00000000-0000-0000-0000-000000000216', 'SUNDAY', '05:00', '23:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101601', '00000000-0000-0000-0000-000000000216', 'Sân 1', 'STANDARD', 70000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675017/badbook/alobo-seed/haan-badminton-club.png', 'ACTIVE', 'HAAN Badminton Club - sân số 1') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101602', '00000000-0000-0000-0000-000000000216', 'Sân 2', 'STANDARD', 70000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675017/badbook/alobo-seed/haan-badminton-club.png', 'ACTIVE', 'HAAN Badminton Club - sân số 2') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101603', '00000000-0000-0000-0000-000000000216', 'Sân 3', 'STANDARD', 70000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675017/badbook/alobo-seed/haan-badminton-club.png', 'ACTIVE', 'HAAN Badminton Club - sân số 3') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;

-- 17. Sân cầu lông Station 217 Mã Lò
-- Sources: https://www.alobo.vn/san-cau-long-station-217-ma-lo/
-- Booking URL: https://datlich.alobo.vn/san/sport_tram_cau_long_station_badminton
INSERT INTO users (id, name, email, password, phone, image_id, created_at, is_deleted) VALUES
  ('00000000-0000-0000-0000-000000000117', 'Quản lý Sân cầu lông Station 217 Mã Lò', 'seed.alobo.station-217-ma-lo@badbook.local', '$2a$10$.Kg4C4UFpowiqgkHbCYhPuh3hKZkgFApkQ7H4kJKGpmIKSYLndJI6', '0900000117', NULL, CURRENT_TIMESTAMP, FALSE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  password = EXCLUDED.password,
  phone = EXCLUDED.phone,
  is_deleted = FALSE;
INSERT INTO user_roles (user_id, role_name) VALUES ('00000000-0000-0000-0000-000000000117', 'VENUE_MANAGER') ON CONFLICT DO NOTHING;
INSERT INTO venues (id, owner_id, name, address, latitude, longitude, description, banner_ids, license_id, status, open_time, close_time, platform_fee_rate, bank_name, bank_number, bank_account_name, created_at) VALUES
  ('00000000-0000-0000-0000-000000000217', '00000000-0000-0000-0000-000000000117', 'Sân cầu lông Station 217 Mã Lò', '217 Mã Lò, Bình Trị Đông A, Bình Tân, TP.HCM', 10.77320000, 106.61190000, 'Station 217 Mã Lò là cụm sân mới tại Bình Tân với 9 sân chuẩn thi đấu và hạ tầng ánh sáng phù hợp chơi khuya.', 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675020/badbook/alobo-seed/san-cau-long-station-217-ma-lo.jpg', 'ALOBO-SEED-STATION217', 'ACTIVE', '05:00', '23:30', 0.1000, 'Vietcombank', '190000000017', 'QUẢN LÝ SÂN CẦU LÔNG STATION 217 MÃ LÒ', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET
  owner_id = EXCLUDED.owner_id,
  name = EXCLUDED.name,
  address = EXCLUDED.address,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude,
  description = EXCLUDED.description,
  banner_ids = EXCLUDED.banner_ids,
  license_id = EXCLUDED.license_id,
  status = EXCLUDED.status,
  open_time = EXCLUDED.open_time,
  close_time = EXCLUDED.close_time,
  platform_fee_rate = EXCLUDED.platform_fee_rate,
  bank_name = EXCLUDED.bank_name,
  bank_number = EXCLUDED.bank_number,
  bank_account_name = EXCLUDED.bank_account_name;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020171', '00000000-0000-0000-0000-000000000217', 'MONDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020172', '00000000-0000-0000-0000-000000000217', 'TUESDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020173', '00000000-0000-0000-0000-000000000217', 'WEDNESDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020174', '00000000-0000-0000-0000-000000000217', 'THURSDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020175', '00000000-0000-0000-0000-000000000217', 'FRIDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020176', '00000000-0000-0000-0000-000000000217', 'SATURDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020177', '00000000-0000-0000-0000-000000000217', 'SUNDAY', '05:00', '23:30', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101701', '00000000-0000-0000-0000-000000000217', 'Sân 1', 'STANDARD', 110000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675020/badbook/alobo-seed/san-cau-long-station-217-ma-lo.jpg', 'ACTIVE', 'Sân cầu lông Station 217 Mã Lò - sân số 1') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101702', '00000000-0000-0000-0000-000000000217', 'Sân 2', 'STANDARD', 110000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675020/badbook/alobo-seed/san-cau-long-station-217-ma-lo.jpg', 'ACTIVE', 'Sân cầu lông Station 217 Mã Lò - sân số 2') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101703', '00000000-0000-0000-0000-000000000217', 'Sân 3', 'STANDARD', 110000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675020/badbook/alobo-seed/san-cau-long-station-217-ma-lo.jpg', 'ACTIVE', 'Sân cầu lông Station 217 Mã Lò - sân số 3') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101704', '00000000-0000-0000-0000-000000000217', 'Sân 4', 'STANDARD', 110000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675020/badbook/alobo-seed/san-cau-long-station-217-ma-lo.jpg', 'ACTIVE', 'Sân cầu lông Station 217 Mã Lò - sân số 4') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101705', '00000000-0000-0000-0000-000000000217', 'Sân 5', 'STANDARD', 110000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675020/badbook/alobo-seed/san-cau-long-station-217-ma-lo.jpg', 'ACTIVE', 'Sân cầu lông Station 217 Mã Lò - sân số 5') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101706', '00000000-0000-0000-0000-000000000217', 'Sân 6', 'STANDARD', 110000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675020/badbook/alobo-seed/san-cau-long-station-217-ma-lo.jpg', 'ACTIVE', 'Sân cầu lông Station 217 Mã Lò - sân số 6') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101707', '00000000-0000-0000-0000-000000000217', 'Sân 7', 'STANDARD', 110000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675020/badbook/alobo-seed/san-cau-long-station-217-ma-lo.jpg', 'ACTIVE', 'Sân cầu lông Station 217 Mã Lò - sân số 7') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101708', '00000000-0000-0000-0000-000000000217', 'Sân 8', 'STANDARD', 110000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675020/badbook/alobo-seed/san-cau-long-station-217-ma-lo.jpg', 'ACTIVE', 'Sân cầu lông Station 217 Mã Lò - sân số 8') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101709', '00000000-0000-0000-0000-000000000217', 'Sân 9', 'STANDARD', 110000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675020/badbook/alobo-seed/san-cau-long-station-217-ma-lo.jpg', 'ACTIVE', 'Sân cầu lông Station 217 Mã Lò - sân số 9') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;

-- 18. CLB thể thao Liên Châu
-- Sources: https://www.alobo.vn/clb-the-thao-lien-chau/
-- Booking URL: https://datlich.alobo.vn/san/sport_trung_tam_the_thao_lien_chau
INSERT INTO users (id, name, email, password, phone, image_id, created_at, is_deleted) VALUES
  ('00000000-0000-0000-0000-000000000118', 'Quản lý CLB thể thao Liên Châu', 'seed.alobo.lien-chau@badbook.local', '$2a$10$.Kg4C4UFpowiqgkHbCYhPuh3hKZkgFApkQ7H4kJKGpmIKSYLndJI6', '0900000118', NULL, CURRENT_TIMESTAMP, FALSE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  password = EXCLUDED.password,
  phone = EXCLUDED.phone,
  is_deleted = FALSE;
INSERT INTO user_roles (user_id, role_name) VALUES ('00000000-0000-0000-0000-000000000118', 'VENUE_MANAGER') ON CONFLICT DO NOTHING;
INSERT INTO venues (id, owner_id, name, address, latitude, longitude, description, banner_ids, license_id, status, open_time, close_time, platform_fee_rate, bank_name, bank_number, bank_account_name, created_at) VALUES
  ('00000000-0000-0000-0000-000000000218', '00000000-0000-0000-0000-000000000118', 'CLB thể thao Liên Châu', 'Số 7 đường N3, KDC Biconsi, KP Tân Thắng, phường Tân Đông Hiệp, TP.HCM', 10.88650000, 106.77240000, 'Liên Châu là mô hình thể thao kết hợp cầu lông, cafe và khu vui chơi trẻ em, phù hợp nhóm gia đình và đồng nghiệp.', 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675024/badbook/alobo-seed/clb-the-thao-lien-chau.jpg', 'ALOBO-SEED-LIENCHAU', 'ACTIVE', '05:00', '22:00', 0.1000, 'Vietcombank', '190000000018', 'QUẢN LÝ CLB THỂ THAO LIÊN CHÂU', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET
  owner_id = EXCLUDED.owner_id,
  name = EXCLUDED.name,
  address = EXCLUDED.address,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude,
  description = EXCLUDED.description,
  banner_ids = EXCLUDED.banner_ids,
  license_id = EXCLUDED.license_id,
  status = EXCLUDED.status,
  open_time = EXCLUDED.open_time,
  close_time = EXCLUDED.close_time,
  platform_fee_rate = EXCLUDED.platform_fee_rate,
  bank_name = EXCLUDED.bank_name,
  bank_number = EXCLUDED.bank_number,
  bank_account_name = EXCLUDED.bank_account_name;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020181', '00000000-0000-0000-0000-000000000218', 'MONDAY', '05:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020182', '00000000-0000-0000-0000-000000000218', 'TUESDAY', '05:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020183', '00000000-0000-0000-0000-000000000218', 'WEDNESDAY', '05:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020184', '00000000-0000-0000-0000-000000000218', 'THURSDAY', '05:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020185', '00000000-0000-0000-0000-000000000218', 'FRIDAY', '05:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020186', '00000000-0000-0000-0000-000000000218', 'SATURDAY', '05:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020187', '00000000-0000-0000-0000-000000000218', 'SUNDAY', '05:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101801', '00000000-0000-0000-0000-000000000218', 'Sân 1', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675024/badbook/alobo-seed/clb-the-thao-lien-chau.jpg', 'ACTIVE', 'CLB thể thao Liên Châu - sân số 1') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101802', '00000000-0000-0000-0000-000000000218', 'Sân 2', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675024/badbook/alobo-seed/clb-the-thao-lien-chau.jpg', 'ACTIVE', 'CLB thể thao Liên Châu - sân số 2') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101803', '00000000-0000-0000-0000-000000000218', 'Sân 3', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675024/badbook/alobo-seed/clb-the-thao-lien-chau.jpg', 'ACTIVE', 'CLB thể thao Liên Châu - sân số 3') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101804', '00000000-0000-0000-0000-000000000218', 'Sân 4', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675024/badbook/alobo-seed/clb-the-thao-lien-chau.jpg', 'ACTIVE', 'CLB thể thao Liên Châu - sân số 4') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101805', '00000000-0000-0000-0000-000000000218', 'Sân 5', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675024/badbook/alobo-seed/clb-the-thao-lien-chau.jpg', 'ACTIVE', 'CLB thể thao Liên Châu - sân số 5') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101806', '00000000-0000-0000-0000-000000000218', 'Sân 6', 'STANDARD', 100000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675024/badbook/alobo-seed/clb-the-thao-lien-chau.jpg', 'ACTIVE', 'CLB thể thao Liên Châu - sân số 6') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;

-- 19. CLB cầu lông Ao An
-- Sources: https://www.alobo.vn/product/phan-mem-quan-ly-san-cau-long-alobo-3/ | https://sancaulongaoan.com/ | https://hoccaulong.vn/2021/05/15/tong-hop-cac-san-cau-long-tai-thanh-pho-ho-chi-minh-va-cac-tinh-lan-can/
-- Booking URL: not publicly exposed
INSERT INTO users (id, name, email, password, phone, image_id, created_at, is_deleted) VALUES
  ('00000000-0000-0000-0000-000000000119', 'Quản lý CLB cầu lông Ao An', 'seed.alobo.ao-an@badbook.local', '$2a$10$.Kg4C4UFpowiqgkHbCYhPuh3hKZkgFApkQ7H4kJKGpmIKSYLndJI6', '0903070407', NULL, CURRENT_TIMESTAMP, FALSE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  password = EXCLUDED.password,
  phone = EXCLUDED.phone,
  is_deleted = FALSE;
INSERT INTO user_roles (user_id, role_name) VALUES ('00000000-0000-0000-0000-000000000119', 'VENUE_MANAGER') ON CONFLICT DO NOTHING;
INSERT INTO venues (id, owner_id, name, address, latitude, longitude, description, banner_ids, license_id, status, open_time, close_time, platform_fee_rate, bank_name, bank_number, bank_account_name, created_at) VALUES
  ('00000000-0000-0000-0000-000000000219', '00000000-0000-0000-0000-000000000119', 'CLB cầu lông Ao An', '1015 Mỹ Phước - Tân Vạn, phường Bình An, Dĩ An, Bình Dương', 10.91900000, 106.78700000, 'Ao An là sân cầu lông cộng đồng tại Dĩ An, phù hợp người mới chơi và các lớp huấn luyện phong trào.', 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675027/badbook/alobo-seed/clb-cau-long-ao-an.jpg', 'ALOBO-SEED-AOAN', 'ACTIVE', '05:00', '22:00', 0.1000, 'Vietcombank', '190000000019', 'QUẢN LÝ CLB CẦU LÔNG AO AN', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET
  owner_id = EXCLUDED.owner_id,
  name = EXCLUDED.name,
  address = EXCLUDED.address,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude,
  description = EXCLUDED.description,
  banner_ids = EXCLUDED.banner_ids,
  license_id = EXCLUDED.license_id,
  status = EXCLUDED.status,
  open_time = EXCLUDED.open_time,
  close_time = EXCLUDED.close_time,
  platform_fee_rate = EXCLUDED.platform_fee_rate,
  bank_name = EXCLUDED.bank_name,
  bank_number = EXCLUDED.bank_number,
  bank_account_name = EXCLUDED.bank_account_name;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020191', '00000000-0000-0000-0000-000000000219', 'MONDAY', '05:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020192', '00000000-0000-0000-0000-000000000219', 'TUESDAY', '05:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020193', '00000000-0000-0000-0000-000000000219', 'WEDNESDAY', '05:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020194', '00000000-0000-0000-0000-000000000219', 'THURSDAY', '05:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020195', '00000000-0000-0000-0000-000000000219', 'FRIDAY', '05:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020196', '00000000-0000-0000-0000-000000000219', 'SATURDAY', '05:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020197', '00000000-0000-0000-0000-000000000219', 'SUNDAY', '05:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101901', '00000000-0000-0000-0000-000000000219', 'Sân 1', 'STANDARD', 80000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675027/badbook/alobo-seed/clb-cau-long-ao-an.jpg', 'ACTIVE', 'CLB cầu lông Ao An - sân số 1') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101902', '00000000-0000-0000-0000-000000000219', 'Sân 2', 'STANDARD', 80000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675027/badbook/alobo-seed/clb-cau-long-ao-an.jpg', 'ACTIVE', 'CLB cầu lông Ao An - sân số 2') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101903', '00000000-0000-0000-0000-000000000219', 'Sân 3', 'STANDARD', 80000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675027/badbook/alobo-seed/clb-cau-long-ao-an.jpg', 'ACTIVE', 'CLB cầu lông Ao An - sân số 3') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101904', '00000000-0000-0000-0000-000000000219', 'Sân 4', 'STANDARD', 80000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675027/badbook/alobo-seed/clb-cau-long-ao-an.jpg', 'ACTIVE', 'CLB cầu lông Ao An - sân số 4') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101905', '00000000-0000-0000-0000-000000000219', 'Sân 5', 'STANDARD', 80000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675027/badbook/alobo-seed/clb-cau-long-ao-an.jpg', 'ACTIVE', 'CLB cầu lông Ao An - sân số 5') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000101906', '00000000-0000-0000-0000-000000000219', 'Sân 6', 'STANDARD', 80000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675027/badbook/alobo-seed/clb-cau-long-ao-an.jpg', 'ACTIVE', 'CLB cầu lông Ao An - sân số 6') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;

-- 20. Sân cầu lông Minh Nhật
-- Sources: https://www.alobo.vn/product/phan-mem-quan-ly-san-cau-long-alobo/ | https://www.sieuthicaulong.vn/san-cau-long/binh-duong/san-cau-long-minh-nhat-thuan-an-binh-duong
-- Booking URL: not publicly exposed
INSERT INTO users (id, name, email, password, phone, image_id, created_at, is_deleted) VALUES
  ('00000000-0000-0000-0000-000000000120', 'Quản lý Sân cầu lông Minh Nhật', 'seed.alobo.minh-nhat@badbook.local', '$2a$10$.Kg4C4UFpowiqgkHbCYhPuh3hKZkgFApkQ7H4kJKGpmIKSYLndJI6', '0900000120', NULL, CURRENT_TIMESTAMP, FALSE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  password = EXCLUDED.password,
  phone = EXCLUDED.phone,
  is_deleted = FALSE;
INSERT INTO user_roles (user_id, role_name) VALUES ('00000000-0000-0000-0000-000000000120', 'VENUE_MANAGER') ON CONFLICT DO NOTHING;
INSERT INTO venues (id, owner_id, name, address, latitude, longitude, description, banner_ids, license_id, status, open_time, close_time, platform_fee_rate, bank_name, bank_number, bank_account_name, created_at) VALUES
  ('00000000-0000-0000-0000-000000000220', '00000000-0000-0000-0000-000000000120', 'Sân cầu lông Minh Nhật', 'Thuận An, Bình Dương', 10.89400000, 106.70100000, 'Minh Nhật là sân cầu lông tại Thuận An, Bình Dương với không gian rộng và 6 sân tiêu chuẩn cho chơi phong trào.', 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675029/badbook/alobo-seed/san-cau-long-minh-nhat.jpg', 'ALOBO-SEED-MINHNHAT', 'ACTIVE', '05:00', '22:00', 0.1000, 'Vietcombank', '190000000020', 'QUẢN LÝ SÂN CẦU LÔNG MINH NHẬT', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET
  owner_id = EXCLUDED.owner_id,
  name = EXCLUDED.name,
  address = EXCLUDED.address,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude,
  description = EXCLUDED.description,
  banner_ids = EXCLUDED.banner_ids,
  license_id = EXCLUDED.license_id,
  status = EXCLUDED.status,
  open_time = EXCLUDED.open_time,
  close_time = EXCLUDED.close_time,
  platform_fee_rate = EXCLUDED.platform_fee_rate,
  bank_name = EXCLUDED.bank_name,
  bank_number = EXCLUDED.bank_number,
  bank_account_name = EXCLUDED.bank_account_name;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020201', '00000000-0000-0000-0000-000000000220', 'MONDAY', '05:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020202', '00000000-0000-0000-0000-000000000220', 'TUESDAY', '05:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020203', '00000000-0000-0000-0000-000000000220', 'WEDNESDAY', '05:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020204', '00000000-0000-0000-0000-000000000220', 'THURSDAY', '05:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020205', '00000000-0000-0000-0000-000000000220', 'FRIDAY', '05:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020206', '00000000-0000-0000-0000-000000000220', 'SATURDAY', '05:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO venue_operating_hours (id, venue_id, day_of_week, open_time, close_time, is_closed) VALUES ('00000000-0000-0000-0000-000000020207', '00000000-0000-0000-0000-000000000220', 'SUNDAY', '05:00', '22:00', FALSE) ON CONFLICT (venue_id, day_of_week) DO UPDATE SET open_time = EXCLUDED.open_time, close_time = EXCLUDED.close_time, is_closed = FALSE;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000102001', '00000000-0000-0000-0000-000000000220', 'Sân 1', 'STANDARD', 90000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675029/badbook/alobo-seed/san-cau-long-minh-nhat.jpg', 'ACTIVE', 'Sân cầu lông Minh Nhật - sân số 1') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000102002', '00000000-0000-0000-0000-000000000220', 'Sân 2', 'STANDARD', 90000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675029/badbook/alobo-seed/san-cau-long-minh-nhat.jpg', 'ACTIVE', 'Sân cầu lông Minh Nhật - sân số 2') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000102003', '00000000-0000-0000-0000-000000000220', 'Sân 3', 'STANDARD', 90000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675029/badbook/alobo-seed/san-cau-long-minh-nhat.jpg', 'ACTIVE', 'Sân cầu lông Minh Nhật - sân số 3') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000102004', '00000000-0000-0000-0000-000000000220', 'Sân 4', 'STANDARD', 90000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675029/badbook/alobo-seed/san-cau-long-minh-nhat.jpg', 'ACTIVE', 'Sân cầu lông Minh Nhật - sân số 4') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000102005', '00000000-0000-0000-0000-000000000220', 'Sân 5', 'STANDARD', 90000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675029/badbook/alobo-seed/san-cau-long-minh-nhat.jpg', 'ACTIVE', 'Sân cầu lông Minh Nhật - sân số 5') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;
INSERT INTO courts (id, venue_id, name, court_type, price_per_hour, image_ids, status, description) VALUES ('00000000-0000-0000-0000-000000102006', '00000000-0000-0000-0000-000000000220', 'Sân 6', 'STANDARD', 90000.00, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780675029/badbook/alobo-seed/san-cau-long-minh-nhat.jpg', 'ACTIVE', 'Sân cầu lông Minh Nhật - sân số 6') ON CONFLICT (id) DO UPDATE SET venue_id = EXCLUDED.venue_id, name = EXCLUDED.name, court_type = EXCLUDED.court_type, price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status, description = EXCLUDED.description;

-- Demo review users, venue products, completed bookings, and venue reviews.
-- Product image placeholders below are resolved by apps/backend/scripts/upload_alobo_images.py before seeding.
INSERT INTO users (id, name, email, password, phone, image_id, created_at, is_deleted) VALUES
  ('00000000-0000-0000-0000-000000000301', 'Nguyễn Hoàng Anh', 'seed.reviewer.01@badbook.local', '$2a$10$.Kg4C4UFpowiqgkHbCYhPuh3hKZkgFApkQ7H4kJKGpmIKSYLndJI6', '0900000301', NULL, CURRENT_TIMESTAMP, FALSE),
  ('00000000-0000-0000-0000-000000000302', 'Trần Minh Khang', 'seed.reviewer.02@badbook.local', '$2a$10$.Kg4C4UFpowiqgkHbCYhPuh3hKZkgFApkQ7H4kJKGpmIKSYLndJI6', '0900000302', NULL, CURRENT_TIMESTAMP, FALSE),
  ('00000000-0000-0000-0000-000000000303', 'Lê Gia Hân', 'seed.reviewer.03@badbook.local', '$2a$10$.Kg4C4UFpowiqgkHbCYhPuh3hKZkgFApkQ7H4kJKGpmIKSYLndJI6', '0900000303', NULL, CURRENT_TIMESTAMP, FALSE),
  ('00000000-0000-0000-0000-000000000304', 'Phạm Quốc Việt', 'seed.reviewer.04@badbook.local', '$2a$10$.Kg4C4UFpowiqgkHbCYhPuh3hKZkgFApkQ7H4kJKGpmIKSYLndJI6', '0900000304', NULL, CURRENT_TIMESTAMP, FALSE),
  ('00000000-0000-0000-0000-000000000305', 'Đỗ Thuỳ Linh', 'seed.reviewer.05@badbook.local', '$2a$10$.Kg4C4UFpowiqgkHbCYhPuh3hKZkgFApkQ7H4kJKGpmIKSYLndJI6', '0900000305', NULL, CURRENT_TIMESTAMP, FALSE)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  password = EXCLUDED.password,
  phone = EXCLUDED.phone,
  is_deleted = FALSE;

INSERT INTO user_roles (user_id, role_name) VALUES
  ('00000000-0000-0000-0000-000000000301', 'USER'),
  ('00000000-0000-0000-0000-000000000302', 'USER'),
  ('00000000-0000-0000-0000-000000000303', 'USER'),
  ('00000000-0000-0000-0000-000000000304', 'USER'),
  ('00000000-0000-0000-0000-000000000305', 'USER')
ON CONFLICT DO NOTHING;

WITH seed_venues AS (
  SELECT v.id AS venue_id, ROW_NUMBER() OVER (ORDER BY v.id)::int AS venue_seq
  FROM venues v
  WHERE v.license_id LIKE 'ALOBO-SEED-%'
),
product_templates (template_seq, name, description, category, price, unit, stock, image_url) AS (
  VALUES
    (1, 'Thuê vợt Yonex Astrox 01 Clear', 'Vợt trợ lực, dễ điều khiển cho khách thuê theo buổi và người mới chơi.', 'RACKET_RENTAL', 50000.00, 'vợt/buổi', 12, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780716757/badbook/alobo-seed/product-thue-vot-yonex-astrox-01-clear.png'),
    (2, 'Thuê vợt Yonex Nanoflare Nextage', 'Vợt thiên tốc độ phù hợp khách đánh đôi, đã quấn cán và bảo dưỡng định kỳ.', 'RACKET_RENTAL', 70000.00, 'vợt/buổi', 8, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780716760/badbook/alobo-seed/product-thue-vot-yonex-nanoflare-nextage.png'),
    (3, 'Ống cầu Yonex Mavis 300', 'Ống cầu nylon bền, phù hợp tập luyện và đánh phong trào hằng ngày.', 'SHUTTLECOCK', 165000.00, 'ống', 30, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780716765/badbook/alobo-seed/product-ong-cau-yonex-mavis-300.jpg'),
    (4, 'Ống cầu Yonex Aerosensa 30', 'Cầu lông lông vũ dành cho trận chất lượng cao và kèo đấu cuối tuần.', 'SHUTTLECOCK', 520000.00, 'ống', 12, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780716771/badbook/alobo-seed/product-ong-cau-yonex-aerosensa-30.png'),
    (5, 'Cuốn cán Yonex Wet Super Grap', 'Cuốn cán bám tay, thấm mồ hôi tốt cho người chơi cường độ cao.', 'EQUIPMENT', 35000.00, 'cuốn', 40, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780716774/badbook/alobo-seed/product-cuon-can-yonex-wet-super-grap.png'),
    (6, 'Nước suối Aquafina 500ml', 'Nước uống đóng chai phục vụ nhanh tại quầy lễ tân và khu nghỉ.', 'BEVERAGE', 10000.00, 'chai', 96, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780716777/badbook/alobo-seed/product-nuoc-suoi-aquafina-500ml.png'),
    (7, 'Nước điện giải Gatorade Water', 'Nước điện giải nhẹ, hợp người chơi cần bù khoáng sau buổi tối.', 'BEVERAGE', 25000.00, 'chai', 60, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780716780/badbook/alobo-seed/product-nuoc-ien-giai-gatorade-water.png'),
    (8, 'Nước thể thao Propel Lemon', 'Đồ uống vị chanh, phù hợp khách đặt sân dài giờ hoặc thi đấu mini.', 'BEVERAGE', 22000.00, 'chai', 48, 'https://res.cloudinary.com/dmlz8xuq1/image/upload/v1780716784/badbook/alobo-seed/product-nuoc-the-thao-propel-lemon.png')
)
INSERT INTO products (id, venue_id, name, description, category, price, unit, stock, image_id, is_active)
SELECT
  format('00000000-0000-0000-%s-%s', lpad((3100 + sv.venue_seq)::text, 4, '0'), lpad(pt.template_seq::text, 12, '0'))::uuid,
  sv.venue_id,
  pt.name,
  pt.description,
  pt.category,
  pt.price,
  pt.unit,
  pt.stock,
  pt.image_url,
  TRUE
FROM seed_venues sv
CROSS JOIN product_templates pt
ON CONFLICT (id) DO UPDATE SET
  venue_id = EXCLUDED.venue_id,
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  category = EXCLUDED.category,
  price = EXCLUDED.price,
  unit = EXCLUDED.unit,
  stock = EXCLUDED.stock,
  image_id = EXCLUDED.image_id,
  is_active = EXCLUDED.is_active;

WITH seed_venues AS (
  SELECT
    v.id AS venue_id,
    v.platform_fee_rate,
    ROW_NUMBER() OVER (ORDER BY v.id)::int AS venue_seq,
    COUNT(c.id)::int AS court_count
  FROM venues v
  LEFT JOIN courts c ON c.venue_id = v.id
  WHERE v.license_id LIKE 'ALOBO-SEED-%'
  GROUP BY v.id, v.platform_fee_rate
),
seed_courts AS (
  SELECT
    c.id AS court_id,
    c.venue_id,
    c.price_per_hour,
    ROW_NUMBER() OVER (PARTITION BY c.venue_id ORDER BY c.name, c.id)::int AS court_seq
  FROM courts c
  JOIN seed_venues sv ON sv.venue_id = c.venue_id
),
review_templates (template_seq, reviewer_id, rating, content, reply_text, add_on_product_seq, add_on_quantity, start_time, notes) AS (
  VALUES
    (1, '00000000-0000-0000-0000-000000000301'::uuid, 5, 'Sân sáng, sạch và nhân viên hỗ trợ nhận sân rất nhanh. Đội mình sẽ quay lại.', 'Cảm ơn anh/chị, bên em luôn giữ sàn và ánh sáng ổn định mỗi ngày.', 3, 1, '18:00'::time, 'Đặt sân sau giờ làm'),
    (2, '00000000-0000-0000-0000-000000000302'::uuid, 5, 'Chỗ để xe rộng, quầy nước đủ đồ và giờ cao điểm vẫn phục vụ ổn.', NULL, 6, 2, '19:00'::time, 'Nhóm 4 người đánh đôi'),
    (3, '00000000-0000-0000-0000-000000000303'::uuid, 4, 'Mặt sân ổn, điều hoà và quạt chạy tốt. Nếu nhà vệ sinh sạch hơn nữa thì trọn vẹn.', 'Bên em đã tăng lịch vệ sinh cuối ca tối, mong lần tới chị thấy thuận tiện hơn.', 7, 1, '20:00'::time, 'Đặt sân tối muộn'),
    (4, '00000000-0000-0000-0000-000000000304'::uuid, 4, 'Giá sân hợp lý, cầu và phụ kiện bán ngay tại quầy nên khá tiện.', NULL, 5, 1, '17:30'::time, 'Mang theo 1 khách mới'),
    (5, '00000000-0000-0000-0000-000000000305'::uuid, 5, 'Không gian thoáng, phù hợp cả đánh phong trào lẫn đặt cố định theo tuần.', 'Cảm ơn chị đã phản hồi tích cực, bên em luôn sẵn sàng giữ lịch cố định cho đội.', NULL, NULL, '21:00'::time, 'Kèo cố định cuối tuần')
),
booking_source AS (
  SELECT
    sv.venue_seq,
    rt.template_seq,
    format('00000000-0000-0000-%s-%s', lpad((4100 + sv.venue_seq)::text, 4, '0'), lpad(rt.template_seq::text, 12, '0'))::uuid AS booking_id,
    rt.reviewer_id AS user_id,
    sc.court_id,
    sv.venue_id,
    CURRENT_DATE - (sv.venue_seq + rt.template_seq + 10) AS booking_date,
    rt.start_time,
    (rt.start_time + INTERVAL '2 hours')::time AS end_time,
    (sc.price_per_hour * 2) AS court_total,
    COALESCE(p.id, NULL) AS add_on_product_id,
    p.name AS add_on_product_name,
    COALESCE(rt.add_on_quantity, 0) AS add_on_quantity,
    COALESCE(p.price, 0::numeric) AS add_on_unit_price,
    COALESCE(p.price * rt.add_on_quantity, 0::numeric) AS add_on_total,
    (sc.price_per_hour * 2) + COALESCE(p.price * rt.add_on_quantity, 0::numeric) AS total_amount,
    sv.platform_fee_rate,
    rt.rating,
    rt.content,
    rt.reply_text,
    rt.notes,
    (CURRENT_TIMESTAMP - ((sv.venue_seq + rt.template_seq + 5) || ' days')::interval) AS created_at,
    (CURRENT_TIMESTAMP - ((sv.venue_seq + rt.template_seq + 4) || ' days')::interval) AS updated_at
  FROM seed_venues sv
  JOIN review_templates rt ON TRUE
  JOIN seed_courts sc
    ON sc.venue_id = sv.venue_id
   AND sc.court_seq = ((rt.template_seq - 1) % sv.court_count) + 1
  LEFT JOIN products p
    ON p.id = CASE
      WHEN rt.add_on_product_seq IS NULL THEN NULL
      ELSE format('00000000-0000-0000-%s-%s', lpad((3100 + sv.venue_seq)::text, 4, '0'), lpad(rt.add_on_product_seq::text, 12, '0'))::uuid
    END
)
INSERT INTO bookings (id, user_id, court_id, venue_id, booking_date, start_time, end_time, type, status, total_amount, notes, cancel_reason, created_at, updated_at)
SELECT
  bs.booking_id,
  bs.user_id,
  bs.court_id,
  bs.venue_id,
  bs.booking_date,
  bs.start_time,
  bs.end_time,
  'HOURLY',
  'COMPLETED',
  bs.total_amount,
  bs.notes,
  NULL,
  bs.created_at,
  bs.updated_at
FROM booking_source bs
ON CONFLICT (id) DO UPDATE SET
  user_id = EXCLUDED.user_id,
  court_id = EXCLUDED.court_id,
  venue_id = EXCLUDED.venue_id,
  booking_date = EXCLUDED.booking_date,
  start_time = EXCLUDED.start_time,
  end_time = EXCLUDED.end_time,
  type = EXCLUDED.type,
  status = EXCLUDED.status,
  total_amount = EXCLUDED.total_amount,
  notes = EXCLUDED.notes,
  cancel_reason = EXCLUDED.cancel_reason,
  created_at = EXCLUDED.created_at,
  updated_at = EXCLUDED.updated_at;

WITH seed_venues AS (
  SELECT
    v.id AS venue_id,
    v.platform_fee_rate,
    ROW_NUMBER() OVER (ORDER BY v.id)::int AS venue_seq,
    COUNT(c.id)::int AS court_count
  FROM venues v
  LEFT JOIN courts c ON c.venue_id = v.id
  WHERE v.license_id LIKE 'ALOBO-SEED-%'
  GROUP BY v.id, v.platform_fee_rate
),
seed_courts AS (
  SELECT
    c.id AS court_id,
    c.venue_id,
    c.price_per_hour,
    ROW_NUMBER() OVER (PARTITION BY c.venue_id ORDER BY c.name, c.id)::int AS court_seq
  FROM courts c
  JOIN seed_venues sv ON sv.venue_id = c.venue_id
),
review_templates (template_seq, add_on_product_seq, add_on_quantity) AS (
  VALUES
    (1, 3, 1),
    (2, 6, 2),
    (3, 7, 1),
    (4, 5, 1),
    (5, NULL, NULL)
),
booking_product_source AS (
  SELECT
    sv.venue_seq,
    rt.template_seq,
    format('00000000-0000-0000-%s-%s', lpad((4100 + sv.venue_seq)::text, 4, '0'), lpad(rt.template_seq::text, 12, '0'))::uuid AS booking_id,
    p.id AS product_id,
    p.name AS product_name,
    rt.add_on_quantity AS quantity,
    p.price AS unit_price,
    p.price * rt.add_on_quantity AS total_price
  FROM seed_venues sv
  JOIN review_templates rt ON rt.add_on_product_seq IS NOT NULL
  JOIN seed_courts sc
    ON sc.venue_id = sv.venue_id
   AND sc.court_seq = ((rt.template_seq - 1) % sv.court_count) + 1
  JOIN products p
    ON p.id = format('00000000-0000-0000-%s-%s', lpad((3100 + sv.venue_seq)::text, 4, '0'), lpad(rt.add_on_product_seq::text, 12, '0'))::uuid
)
INSERT INTO booking_products (id, booking_id, product_id, product_name, quantity, unit_price, total_price)
SELECT
  format('00000000-0000-0000-%s-%s', lpad((7100 + bps.venue_seq)::text, 4, '0'), lpad(bps.template_seq::text, 12, '0'))::uuid,
  bps.booking_id,
  bps.product_id,
  bps.product_name,
  bps.quantity,
  bps.unit_price,
  bps.total_price
FROM booking_product_source bps
ON CONFLICT (id) DO UPDATE SET
  booking_id = EXCLUDED.booking_id,
  product_id = EXCLUDED.product_id,
  product_name = EXCLUDED.product_name,
  quantity = EXCLUDED.quantity,
  unit_price = EXCLUDED.unit_price,
  total_price = EXCLUDED.total_price;

WITH seed_venues AS (
  SELECT
    v.id AS venue_id,
    v.platform_fee_rate,
    ROW_NUMBER() OVER (ORDER BY v.id)::int AS venue_seq,
    COUNT(c.id)::int AS court_count
  FROM venues v
  LEFT JOIN courts c ON c.venue_id = v.id
  WHERE v.license_id LIKE 'ALOBO-SEED-%'
  GROUP BY v.id, v.platform_fee_rate
),
seed_courts AS (
  SELECT
    c.id AS court_id,
    c.venue_id,
    c.price_per_hour,
    ROW_NUMBER() OVER (PARTITION BY c.venue_id ORDER BY c.name, c.id)::int AS court_seq
  FROM courts c
  JOIN seed_venues sv ON sv.venue_id = c.venue_id
),
review_templates (template_seq, add_on_product_seq, add_on_quantity) AS (
  VALUES
    (1, 3, 1),
    (2, 6, 2),
    (3, 7, 1),
    (4, 5, 1),
    (5, NULL, NULL)
),
finance_source AS (
  SELECT
    sv.venue_seq,
    rt.template_seq,
    format('00000000-0000-0000-%s-%s', lpad((4100 + sv.venue_seq)::text, 4, '0'), lpad(rt.template_seq::text, 12, '0'))::uuid AS booking_id,
    (sc.price_per_hour * 2) + COALESCE(p.price * rt.add_on_quantity, 0::numeric) AS total_amount,
    ROUND(((sc.price_per_hour * 2) + COALESCE(p.price * rt.add_on_quantity, 0::numeric)) * sv.platform_fee_rate, 2) AS platform_fee_amount
  FROM seed_venues sv
  JOIN review_templates rt ON TRUE
  JOIN seed_courts sc
    ON sc.venue_id = sv.venue_id
   AND sc.court_seq = ((rt.template_seq - 1) % sv.court_count) + 1
  LEFT JOIN products p
    ON p.id = CASE
      WHEN rt.add_on_product_seq IS NULL THEN NULL
      ELSE format('00000000-0000-0000-%s-%s', lpad((3100 + sv.venue_seq)::text, 4, '0'), lpad(rt.add_on_product_seq::text, 12, '0'))::uuid
    END
)
INSERT INTO finances (id, booking_id, total_amount, platform_fee_amount, venue_revenue, status)
SELECT
  format('00000000-0000-0000-%s-%s', lpad((6100 + fs.venue_seq)::text, 4, '0'), lpad(fs.template_seq::text, 12, '0'))::uuid,
  fs.booking_id,
  fs.total_amount,
  fs.platform_fee_amount,
  fs.total_amount - fs.platform_fee_amount,
  'COMPLETED'
FROM finance_source fs
ON CONFLICT (id) DO UPDATE SET
  booking_id = EXCLUDED.booking_id,
  total_amount = EXCLUDED.total_amount,
  platform_fee_amount = EXCLUDED.platform_fee_amount,
  venue_revenue = EXCLUDED.venue_revenue,
  status = EXCLUDED.status;

WITH seed_venues AS (
  SELECT v.id AS venue_id, ROW_NUMBER() OVER (ORDER BY v.id)::int AS venue_seq
  FROM venues v
  WHERE v.license_id LIKE 'ALOBO-SEED-%'
),
review_templates (template_seq, reviewer_id, rating, content, reply_text) AS (
  VALUES
    (1, '00000000-0000-0000-0000-000000000301'::uuid, 5, 'Sân sáng, sạch và nhân viên hỗ trợ nhận sân rất nhanh. Đội mình sẽ quay lại.', 'Cảm ơn anh/chị, bên em luôn giữ sàn và ánh sáng ổn định mỗi ngày.'),
    (2, '00000000-0000-0000-0000-000000000302'::uuid, 5, 'Chỗ để xe rộng, quầy nước đủ đồ và giờ cao điểm vẫn phục vụ ổn.', NULL),
    (3, '00000000-0000-0000-0000-000000000303'::uuid, 4, 'Mặt sân ổn, điều hoà và quạt chạy tốt. Nếu nhà vệ sinh sạch hơn nữa thì trọn vẹn.', 'Bên em đã tăng lịch vệ sinh cuối ca tối, mong lần tới chị thấy thuận tiện hơn.'),
    (4, '00000000-0000-0000-0000-000000000304'::uuid, 4, 'Giá sân hợp lý, cầu và phụ kiện bán ngay tại quầy nên khá tiện.', NULL),
    (5, '00000000-0000-0000-0000-000000000305'::uuid, 5, 'Không gian thoáng, phù hợp cả đánh phong trào lẫn đặt cố định theo tuần.', 'Cảm ơn chị đã phản hồi tích cực, bên em luôn sẵn sàng giữ lịch cố định cho đội.')
)
INSERT INTO reviews (id, user_id, booking_id, target_type, target_id, rating, content, reply_text, reply_at, is_deleted, created_at)
SELECT
  format('00000000-0000-0000-%s-%s', lpad((5100 + sv.venue_seq)::text, 4, '0'), lpad(rt.template_seq::text, 12, '0'))::uuid,
  rt.reviewer_id,
  format('00000000-0000-0000-%s-%s', lpad((4100 + sv.venue_seq)::text, 4, '0'), lpad(rt.template_seq::text, 12, '0'))::uuid,
  'VENUE',
  sv.venue_id,
  rt.rating,
  rt.content,
  rt.reply_text,
  CASE
    WHEN rt.reply_text IS NULL THEN NULL
    ELSE CURRENT_TIMESTAMP - ((sv.venue_seq + rt.template_seq + 2) || ' days')::interval
  END,
  FALSE,
  CURRENT_TIMESTAMP - ((sv.venue_seq + rt.template_seq + 3) || ' days')::interval
FROM seed_venues sv
CROSS JOIN review_templates rt
ON CONFLICT (id) DO UPDATE SET
  user_id = EXCLUDED.user_id,
  booking_id = EXCLUDED.booking_id,
  target_type = EXCLUDED.target_type,
  target_id = EXCLUDED.target_id,
  rating = EXCLUDED.rating,
  content = EXCLUDED.content,
  reply_text = EXCLUDED.reply_text,
  reply_at = EXCLUDED.reply_at,
  is_deleted = EXCLUDED.is_deleted,
  created_at = EXCLUDED.created_at;
