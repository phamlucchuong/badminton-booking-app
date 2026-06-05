#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import mimetypes
import re
import sys
import time
import unicodedata
from pathlib import Path
from urllib.parse import urlparse

import requests

REPO_ROOT = Path(__file__).resolve().parents[3]
BACKEND_ENV = REPO_ROOT / 'apps/backend/.env'
SEED_SQL = REPO_ROOT / 'apps/backend/scripts/seed_alobo.sql'
MANIFEST_JSON = REPO_ROOT / 'apps/backend/scripts/alobo_image_manifest.json'
DOWNLOAD_DIR = Path('/tmp/badbook_alobo_images')
CLOUDINARY_FOLDER = 'badbook/alobo-seed'
USER_AGENT = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0 Safari/537.36'
TIMEOUT = 60

VENUE_IMAGE_SOURCES = [
    {
        'venue_name': 'Sân cầu lông Viện 354',
        'source_page': 'https://www.alobo.vn/san-cau-long-ha-noi/',
        'source_image_url': 'https://babolat.com.vn/wp-content/uploads/2023/11/san-cau-long-ha-noi-354.jpg',
    },
    {
        'venue_name': 'Sân cầu lông Nhà văn hoá Mai Dịch',
        'source_page': 'https://www.alobo.vn/san-cau-long-ha-noi/',
        'source_image_url': 'https://www.alobo.vn/wp-content/uploads/2025/07/image-8.png',
    },
    {
        'venue_name': 'Sân 521 Minh Khai',
        'source_page': 'https://qvbadminton.com/thue-san-cau-long/',
        'source_image_url': 'https://babolat.com.vn/wp-content/uploads/2023/11/san-521-minh-khai.jpg',
    },
    {
        'venue_name': 'Sân cầu lông BMC Club',
        'source_page': 'https://www.alobo.vn/san-cau-long-bmc-ung-dung-alobo/',
        'source_image_url': 'https://www.alobo.vn/wp-content/uploads/2025/07/san-cau-long-bmc-banner-1715674630.jpeg',
    },
    {
        'venue_name': 'Sân cầu lông HG',
        'source_page': 'https://www.alobo.vn/san-cau-long-ha-noi/',
        'source_image_url': 'https://www.alobo.vn/wp-content/uploads/2025/07/image-4-2000x2000.png',
    },
    {
        'venue_name': 'Sân cầu lông TDT 314 Bùi Xương Trạch',
        'source_page': 'https://www.alobo.vn/san-cau-long-tdt-314-bui-xuong-trach/',
        'source_image_url': 'https://www.alobo.vn/wp-content/uploads/2025/10/image-11.png',
    },
    {
        'venue_name': 'Sân cầu lông Eco',
        'source_page': 'https://www.alobo.vn/dia-chi-thue-san-cau-long-tren-app-alobo/',
        'source_image_url': 'https://www.alobo.vn/wp-content/uploads/2024/09/eco-1.jpg',
    },
    {
        'venue_name': 'Sân cầu lông ECOSPORT',
        'source_page': 'https://www.alobo.vn/dia-chi-thue-san-cau-long-tren-app-alobo/',
        'source_image_url': 'https://www.alobo.vn/wp-content/uploads/2024/09/image-13.png',
    },
    {
        'venue_name': 'CLB Cầu lông Hoàng Văn Thụ',
        'source_page': 'https://www.alobo.vn/dia-chi-thue-san-cau-long-tren-app-alobo/',
        'source_image_url': 'https://www.alobo.vn/wp-content/uploads/2024/09/image-14.png',
    },
    {
        'venue_name': 'Sân cầu lông Hồng Châu',
        'source_page': 'https://www.alobo.vn/dia-chi-thue-san-cau-long-tren-app-alobo/',
        'source_image_url': 'https://www.alobo.vn/wp-content/uploads/2024/09/hongchau2-1.jpg',
    },
    {
        'venue_name': 'CLB Cầu lông Trường Chinh 909',
        'source_page': 'https://www.alobo.vn/dia-chi-thue-san-cau-long-tren-app-alobo/',
        'source_image_url': 'https://www.alobo.vn/wp-content/uploads/2024/09/image-22.png',
    },
    {
        'venue_name': 'CLB Cầu lông Gia Hân',
        'source_page': 'https://www.alobo.vn/dia-chi-thue-san-cau-long-tren-app-alobo/',
        'source_image_url': 'https://www.alobo.vn/wp-content/uploads/2024/09/image-27.png',
    },
    {
        'venue_name': 'Sân cầu lông Sky Badminton',
        'source_page': 'https://www.alobo.vn/dia-chi-thue-san-cau-long-tren-app-alobo/',
        'source_image_url': 'https://www.alobo.vn/wp-content/uploads/2024/09/image-33.png',
    },
    {
        'venue_name': 'Sân cầu lông 68',
        'source_page': 'https://www.alobo.vn/dia-chi-thue-san-cau-long-tren-app-alobo/',
        'source_image_url': 'https://www.alobo.vn/wp-content/uploads/2024/09/image-34.png',
    },
    {
        'venue_name': 'CLB Cầu lông Hòa Bình',
        'source_page': 'https://www.alobo.vn/dia-chi-thue-san-cau-long-tren-app-alobo/',
        'source_image_url': 'https://www.alobo.vn/wp-content/uploads/2024/09/image-37.png',
    },
    {
        'venue_name': 'HAAN Badminton Club',
        'source_page': 'https://www.alobo.vn/dia-chi-thue-san-cau-long-tren-app-alobo/',
        'source_image_url': 'https://www.alobo.vn/wp-content/uploads/2024/09/image-38.png',
    },
    {
        'venue_name': 'Sân cầu lông Station 217 Mã Lò',
        'source_page': 'https://www.alobo.vn/san-cau-long-station-217-ma-lo/',
        'source_image_url': 'https://www.alobo.vn/wp-content/uploads/2025/10/548229158_122106027338999490_4768419173962676603_n.jpg',
    },
    {
        'venue_name': 'CLB thể thao Liên Châu',
        'source_page': 'https://www.alobo.vn/clb-the-thao-lien-chau/',
        'source_image_url': 'https://www.alobo.vn/wp-content/uploads/2025/09/550253522_122096483265040455_3738967649359928427_n.jpg',
    },
    {
        'venue_name': 'CLB cầu lông Ao An',
        'source_page': 'https://cabasports.vn/goc-chia-se/cau-lac-bo-cau-long-ao-an/',
        'source_image_url': 'https://cabasports.vn/wp-content/uploads/2025/06/clb-cau-long-ao-an-tong-quan.jpg',
    },
    {
        'venue_name': 'Sân cầu lông Minh Nhật',
        'source_page': 'https://sportnet.vn/san/san-cau-long-minh-nhat',
        'source_image_url': 'https://sportnet.vn/uploads/venue/378/san-cau-long-minh-nhat-banner-1716798896.jpeg',
    },
]


def parse_env(path: Path) -> dict[str, str]:
    values: dict[str, str] = {}
    for raw_line in path.read_text(encoding='utf-8').splitlines():
        line = raw_line.strip()
        if not line or line.startswith('#') or '=' not in line:
            continue
        key, value = line.split('=', 1)
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        values[key] = value
    return values


def slugify(value: str) -> str:
    normalized = unicodedata.normalize('NFD', value)
    ascii_only = normalized.encode('ascii', 'ignore').decode('ascii')
    slug = re.sub(r'[^a-zA-Z0-9]+', '-', ascii_only.lower()).strip('-')
    return slug or 'venue'


def infer_extension(source_url: str, content_type: str | None) -> str:
    parsed_path = urlparse(source_url).path
    ext = Path(parsed_path).suffix.lower()
    if ext in {'.jpg', '.jpeg', '.png', '.webp'}:
        return ext
    if content_type:
        guessed = mimetypes.guess_extension(content_type.split(';', 1)[0].strip())
        if guessed:
            return '.jpg' if guessed == '.jpe' else guessed
    return '.jpg'


def download_image(session: requests.Session, venue_name: str, source_url: str) -> Path:
    DOWNLOAD_DIR.mkdir(parents=True, exist_ok=True)
    response = session.get(source_url, timeout=TIMEOUT, headers={'User-Agent': USER_AGENT}, stream=True)
    response.raise_for_status()
    ext = infer_extension(source_url, response.headers.get('Content-Type'))
    target = DOWNLOAD_DIR / f"{slugify(venue_name)}{ext}"
    with target.open('wb') as handle:
        for chunk in response.iter_content(chunk_size=1024 * 128):
            if chunk:
                handle.write(chunk)
    return target


def cloudinary_signature(params: dict[str, str], api_secret: str) -> str:
    payload = '&'.join(f'{key}={params[key]}' for key in sorted(params))
    return hashlib.sha1(f'{payload}{api_secret}'.encode('utf-8')).hexdigest()


def upload_to_cloudinary(session: requests.Session, image_path: Path, venue_name: str, env: dict[str, str]) -> dict[str, str]:
    timestamp = str(int(time.time()))
    public_id = slugify(venue_name)
    sign_params = {
        'folder': CLOUDINARY_FOLDER,
        'overwrite': 'true',
        'public_id': public_id,
        'timestamp': timestamp,
        'unique_filename': 'false',
        'use_filename': 'false',
    }
    signature = cloudinary_signature(sign_params, env['CLOUDINARY_API_SECRET'])
    upload_url = f"https://api.cloudinary.com/v1_1/{env['CLOUDINARY_CLOUD_NAME']}/image/upload"
    with image_path.open('rb') as image_file:
        response = session.post(
            upload_url,
            timeout=TIMEOUT,
            data={
                'api_key': env['CLOUDINARY_API_KEY'],
                'folder': CLOUDINARY_FOLDER,
                'overwrite': 'true',
                'public_id': public_id,
                'signature': signature,
                'timestamp': timestamp,
                'unique_filename': 'false',
                'use_filename': 'false',
            },
            files={'file': (image_path.name, image_file)},
        )
    response.raise_for_status()
    payload = response.json()
    secure_url = payload.get('secure_url')
    if not secure_url:
        raise RuntimeError(f'Cloudinary upload for {venue_name} did not return secure_url: {payload}')
    return {
        'public_id': payload['public_id'],
        'secure_url': secure_url,
        'asset_id': payload.get('asset_id', ''),
        'version': str(payload.get('version', '')),
    }


def load_seed_blocks(seed_text: str) -> tuple[str, list[str]]:
    parts = re.split(r'(?m)(?=^-- \d{2}\. )', seed_text)
    prefix = parts[0]
    blocks = [part for part in parts[1:] if part.strip()]
    return prefix, blocks


def update_block(block: str, venue_name: str, secure_url: str) -> str:
    if venue_name not in block:
        return block

    updated = block
    if 'banner_ids = EXCLUDED.banner_ids,' not in updated:
        updated = updated.replace(
            '  description = EXCLUDED.description,\n',
            '  description = EXCLUDED.description,\n  banner_ids = EXCLUDED.banner_ids,\n',
            1,
        )

    updated = re.sub(
        r", (NULL|'[^']*'), 'ALOBO-SEED",
        f", '{secure_url}', 'ALOBO-SEED",
        updated,
        count=1,
    )

    lines = updated.splitlines()
    new_lines = []
    for line in lines:
        if line.startswith('INSERT INTO courts '):
            line = re.sub(
                r", (NULL|'[^']*'), 'ACTIVE',",
                f", '{secure_url}', 'ACTIVE',",
                line,
                count=1,
            )
            if 'image_ids = EXCLUDED.image_ids,' not in line:
                line = line.replace(
                    'price_per_hour = EXCLUDED.price_per_hour, status = EXCLUDED.status,',
                    'price_per_hour = EXCLUDED.price_per_hour, image_ids = EXCLUDED.image_ids, status = EXCLUDED.status,',
                )
        new_lines.append(line)
    return '\n'.join(new_lines) + ('\n' if updated.endswith('\n') else '')


def update_seed_sql(image_manifest: list[dict[str, str]]) -> None:
    seed_text = SEED_SQL.read_text(encoding='utf-8')
    prefix, blocks = load_seed_blocks(seed_text)
    ordered_blocks = []
    for block in blocks:
        match = re.search(r"INSERT INTO venues \(.*?\) VALUES\n  \('[^']+', '[^']+', '([^']+)'", block, re.S)
        venue_name = match.group(1)
        manifest_entry = next((entry for entry in image_manifest if entry['venue_name'] == venue_name), None)
        if manifest_entry is None:
            ordered_blocks.append(block)
            continue
        ordered_blocks.append(update_block(block, venue_name, manifest_entry['cloudinary_secure_url']))

    SEED_SQL.write_text(prefix + ''.join(ordered_blocks), encoding='utf-8')


def main() -> int:
    if not BACKEND_ENV.exists():
        raise RuntimeError(f'Missing backend env file: {BACKEND_ENV}')
    env = parse_env(BACKEND_ENV)
    required_keys = ['CLOUDINARY_CLOUD_NAME', 'CLOUDINARY_API_KEY', 'CLOUDINARY_API_SECRET']
    missing = [key for key in required_keys if not env.get(key)]
    if missing:
        raise RuntimeError(f'Missing Cloudinary config keys in {BACKEND_ENV}: {", ".join(missing)}')

    session = requests.Session()
    session.headers.update({'User-Agent': USER_AGENT})

    manifest: list[dict[str, str]] = []
    for item in VENUE_IMAGE_SOURCES:
        venue_name = item['venue_name']
        image_path = download_image(session, venue_name, item['source_image_url'])
        cloudinary_result = upload_to_cloudinary(session, image_path, venue_name, env)
        manifest.append(
            {
                'venue_name': venue_name,
                'source_page': item['source_page'],
                'source_image_url': item['source_image_url'],
                'downloaded_file': str(image_path),
                'cloudinary_public_id': cloudinary_result['public_id'],
                'cloudinary_secure_url': cloudinary_result['secure_url'],
                'cloudinary_asset_id': cloudinary_result['asset_id'],
                'cloudinary_version': cloudinary_result['version'],
            }
        )
        print(f"Uploaded {venue_name}: {cloudinary_result['secure_url']}")

    MANIFEST_JSON.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    update_seed_sql(manifest)
    print(f'Wrote manifest: {MANIFEST_JSON}')
    print(f'Updated seed SQL: {SEED_SQL}')
    return 0


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except Exception as exc:  # pragma: no cover - operational script
        print(f'ERROR: {exc}', file=sys.stderr)
        raise SystemExit(1)
