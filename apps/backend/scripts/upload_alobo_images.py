#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import mimetypes
import re
import sys
import time
import unicodedata
from html import unescape
from pathlib import Path
from urllib.parse import urljoin, urlparse

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

PRODUCT_IMAGE_SOURCES = [
    {
        'product_name': 'Thuê vợt Yonex Astrox 01 Clear',
        'placeholder': '__PRODUCT_IMAGE_ASTROX_01_CLEAR__',
        'source_page': 'https://www.yonex.com/astrox-01-clear',
    },
    {
        'product_name': 'Thuê vợt Yonex Nanoflare Nextage',
        'placeholder': '__PRODUCT_IMAGE_NANOFLARE_NEXTAGE__',
        'source_page': 'https://www.yonex.com/badminton/racquets/nanoflare/nf-nt',
    },
    {
        'product_name': 'Ống cầu Yonex Mavis 300',
        'placeholder': '__PRODUCT_IMAGE_MAVIS_300__',
        'source_page': 'https://us.yonex.com/products/mavis-300',
    },
    {
        'product_name': 'Ống cầu Yonex Aerosensa 30',
        'placeholder': '__PRODUCT_IMAGE_AEROSENSA_30__',
        'source_page': 'https://us.yonex.com/products/aerosensa-30',
    },
    {
        'product_name': 'Cuốn cán Yonex Wet Super Grap',
        'placeholder': '__PRODUCT_IMAGE_WET_SUPER_GRAP__',
        'source_page': 'https://www.yonex.com/ac102',
    },
    {
        'product_name': 'Nước suối Aquafina 500ml',
        'placeholder': '__PRODUCT_IMAGE_AQUAFINA__',
        'source_page': 'https://www.pepsicoproductfacts.com/Home/Product?gtin=00012000001598',
    },
    {
        'product_name': 'Nước điện giải Gatorade Water',
        'placeholder': '__PRODUCT_IMAGE_GATORADE_WATER__',
        'source_page': 'https://www.pepsicoproductfacts.com/Home/product?gtin=00052000060959',
    },
    {
        'product_name': 'Nước thể thao Propel Lemon',
        'placeholder': '__PRODUCT_IMAGE_PROPEL_LEMON__',
        'source_page': 'https://www.pepsicoproductfacts.com/Home/product?gtin=00052000001679',
    },
]

META_IMAGE_PATTERNS = [
    re.compile(r'<meta[^>]+property=["\']og:image["\'][^>]+content=["\']([^"\']+)["\']', re.IGNORECASE),
    re.compile(r'<meta[^>]+content=["\']([^"\']+)["\'][^>]+property=["\']og:image["\']', re.IGNORECASE),
    re.compile(r'<meta[^>]+name=["\']twitter:image["\'][^>]+content=["\']([^"\']+)["\']', re.IGNORECASE),
    re.compile(r'<meta[^>]+content=["\']([^"\']+)["\'][^>]+name=["\']twitter:image["\']', re.IGNORECASE),
]

IMG_URL_PATTERNS = [
    re.compile(r'["\'](https?:\\?/\\?/[^"\']*content/image/products/[^"\']+)["\']', re.IGNORECASE),
    re.compile(r'["\'](/content/image/products/[^"\']+)["\']', re.IGNORECASE),
    re.compile(r'<img[^>]+(?:src|data-src|data-image)=["\']([^"\']+)["\']', re.IGNORECASE),
    re.compile(r'["\'](https?:\\?/\\?/[^"\']+\.(?:png|jpe?g|webp))(?:\?[^"\']*)?["\']', re.IGNORECASE),
]

BAD_IMAGE_TOKENS = ['logo', 'icon', 'sprite', 'placeholder', 'blank.gif', 'search.svg', 'essentialaccessibility']


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
    return slug or 'asset'


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


def normalize_candidate_url(base_url: str, candidate: str) -> str:
    normalized = unescape(candidate).replace('\\/', '/').strip()
    if normalized.startswith('//'):
        normalized = f'https:{normalized}'
    return urljoin(base_url, normalized)


def is_viable_image_url(candidate: str) -> bool:
    lowered = candidate.lower()
    if not lowered or lowered.startswith('data:'):
        return False
    return not any(token in lowered for token in BAD_IMAGE_TOKENS)


def request_with_retry(session: requests.Session, method: str, url: str, **kwargs) -> requests.Response:
    last_error: requests.RequestException | None = None
    for attempt in range(3):
        try:
            response = session.request(method, url, **kwargs)
            response.raise_for_status()
            return response
        except requests.RequestException as exc:
            last_error = exc
            if attempt == 2:
                raise
            time.sleep(1.5 * (attempt + 1))
    assert last_error is not None
    raise last_error


def resolve_image_url(session: requests.Session, source_page: str, explicit_source_image_url: str | None = None) -> str:
    if explicit_source_image_url:
        return explicit_source_image_url

    response = request_with_retry(
        session,
        'GET',
        source_page,
        timeout=TIMEOUT,
        headers={'User-Agent': USER_AGENT},
    )
    html = response.text

    for pattern in META_IMAGE_PATTERNS:
        match = pattern.search(html)
        if match:
            candidate = normalize_candidate_url(source_page, match.group(1))
            if is_viable_image_url(candidate):
                return candidate

    for pattern in IMG_URL_PATTERNS:
        for match in pattern.finditer(html):
            candidate = normalize_candidate_url(source_page, match.group(1))
            if is_viable_image_url(candidate):
                return candidate

    raise RuntimeError(f'Could not resolve an image from {source_page}')


def download_image(session: requests.Session, label: str, source_url: str) -> Path:
    DOWNLOAD_DIR.mkdir(parents=True, exist_ok=True)
    response = request_with_retry(
        session,
        'GET',
        source_url,
        timeout=TIMEOUT,
        headers={'User-Agent': USER_AGENT},
        stream=True,
    )
    ext = infer_extension(source_url, response.headers.get('Content-Type'))
    target = DOWNLOAD_DIR / f"{slugify(label)}{ext}"
    with target.open('wb') as handle:
        for chunk in response.iter_content(chunk_size=1024 * 128):
            if chunk:
                handle.write(chunk)
    return target


def cloudinary_signature(params: dict[str, str], api_secret: str) -> str:
    payload = '&'.join(f'{key}={params[key]}' for key in sorted(params))
    return hashlib.sha1(f'{payload}{api_secret}'.encode('utf-8')).hexdigest()


def upload_to_cloudinary(session: requests.Session, image_path: Path, public_id: str, env: dict[str, str]) -> dict[str, str]:
    timestamp = str(int(time.time()))
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
        response = request_with_retry(
            session,
            'POST',
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
    payload = response.json()
    secure_url = payload.get('secure_url')
    if not secure_url:
        raise RuntimeError(f'Cloudinary upload for {public_id} did not return secure_url: {payload}')
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
    venue_entries = [entry for entry in image_manifest if entry['asset_type'] == 'venue']
    for block in blocks:
        match = re.search(r"INSERT INTO venues \(.*?\) VALUES\n  \('[^']+', '[^']+', '([^']+)'", block, re.S)
        venue_name = match.group(1)
        manifest_entry = next((entry for entry in venue_entries if entry['venue_name'] == venue_name), None)
        if manifest_entry is None:
            ordered_blocks.append(block)
            continue
        ordered_blocks.append(update_block(block, venue_name, manifest_entry['cloudinary_secure_url']))

    updated_seed = prefix + ''.join(ordered_blocks)
    for entry in image_manifest:
        placeholder = entry.get('placeholder')
        if placeholder:
            updated_seed = updated_seed.replace(placeholder, entry['cloudinary_secure_url'])

    SEED_SQL.write_text(updated_seed, encoding='utf-8')


def upload_asset(session: requests.Session, item: dict[str, str], env: dict[str, str], asset_type: str) -> dict[str, str]:
    display_name = item['venue_name'] if asset_type == 'venue' else item['product_name']
    source_image_url = resolve_image_url(session, item['source_page'], item.get('source_image_url'))
    image_path = download_image(session, display_name, source_image_url)
    public_id = slugify(display_name) if asset_type == 'venue' else f"product-{slugify(display_name)}"
    cloudinary_result = upload_to_cloudinary(session, image_path, public_id, env)
    manifest_entry = {
        'asset_type': asset_type,
        'display_name': display_name,
        'source_page': item['source_page'],
        'source_image_url': source_image_url,
        'downloaded_file': str(image_path),
        'cloudinary_public_id': cloudinary_result['public_id'],
        'cloudinary_secure_url': cloudinary_result['secure_url'],
        'cloudinary_asset_id': cloudinary_result['asset_id'],
        'cloudinary_version': cloudinary_result['version'],
    }
    if asset_type == 'venue':
        manifest_entry['venue_name'] = item['venue_name']
    else:
        manifest_entry['product_name'] = item['product_name']
        manifest_entry['placeholder'] = item['placeholder']
    return manifest_entry


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

    products_only = '--products-only' in sys.argv

    manifest: list[dict[str, str]] = []
    if not products_only:
        for item in VENUE_IMAGE_SOURCES:
            manifest_entry = upload_asset(session, item, env, 'venue')
            manifest.append(manifest_entry)
            print(f"Uploaded venue {manifest_entry['display_name']}: {manifest_entry['cloudinary_secure_url']}")

    for item in PRODUCT_IMAGE_SOURCES:
        manifest_entry = upload_asset(session, item, env, 'product')
        manifest.append(manifest_entry)
        print(f"Uploaded product {manifest_entry['display_name']}: {manifest_entry['cloudinary_secure_url']}")

    MANIFEST_JSON.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    update_seed_sql(manifest)
    print(f'Wrote manifest: {MANIFEST_JSON}')
    print(f'Updated seed SQL: {SEED_SQL}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
