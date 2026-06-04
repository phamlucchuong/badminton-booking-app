package vn.chuongpl.badbook.features.booking;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.chuongpl.badbook.common.PageResponse;
import vn.chuongpl.badbook.common.enums.*;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.booking.dto.request.AddProductRequest;
import vn.chuongpl.badbook.features.booking.dto.request.BookingCreateRequest;
import vn.chuongpl.badbook.features.booking.dto.response.BookingResponse;
import vn.chuongpl.badbook.features.court.Court;
import vn.chuongpl.badbook.features.court.CourtService;
import vn.chuongpl.badbook.features.product.Product;
import vn.chuongpl.badbook.features.product.ProductService;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;
import vn.chuongpl.badbook.features.finance.FinanceService;
import vn.chuongpl.badbook.features.venue.Venue;
import vn.chuongpl.badbook.features.venue.VenueRepository;

import java.math.BigDecimal;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class BookingService {

    BookingRepository bookingRepository;
    BookingProductRepository bookingProductRepository;
    UserRepository userRepository;
    VenueRepository venueRepository;
    CourtService courtService;
    ProductService productService;
    BookingMapper bookingMapper;
    FinanceService financeService;

    @Transactional
    public BookingResponse createBooking(String userId, BookingCreateRequest request) {
        User user = findUser(userId);
        Venue venue = findVenue(request.getVenueId());
        Court court = courtService.findCourt(request.getCourtId());

        if (court.getStatus() != CourtStatus.ACTIVE) throw new AppException(ErrorCode.COURT_NOT_AVAILABLE);
        if (venue.getStatus() != VenueStatus.ACTIVE) throw new AppException(ErrorCode.VENUE_NOT_APPROVED);
        if (!court.getVenue().getId().equals(venue.getId())) throw new AppException(ErrorCode.COURT_NOT_IN_VENUE);

        if (bookingRepository.existsConflict(court, request.getBookingDate(),
                request.getStartTime(), request.getEndTime())) {
            throw new AppException(ErrorCode.BOOKING_CONFLICT);
        }

        long hours = Duration.between(request.getStartTime(), request.getEndTime()).toHours();
        BigDecimal courtAmount = court.getPricePerHour().multiply(BigDecimal.valueOf(hours));

        List<BookingProduct> bookingProducts = new ArrayList<>();
        BigDecimal productsTotal = BigDecimal.ZERO;

        if (request.getProducts() != null) {
            for (AddProductRequest pr : request.getProducts()) {
                Product product = productService.findProduct(pr.getProductId());
                if (!product.getVenue().getId().equals(venue.getId()))
                    throw new AppException(ErrorCode.PRODUCT_NOT_IN_VENUE);
                if (product.getStock() < pr.getQuantity())
                    throw new AppException(ErrorCode.PRODUCT_OUT_OF_STOCK);

                BigDecimal lineTotal = product.getPrice().multiply(BigDecimal.valueOf(pr.getQuantity()));
                productsTotal = productsTotal.add(lineTotal);
                bookingProducts.add(BookingProduct.builder()
                        .product(product).productName(product.getName())
                        .quantity(pr.getQuantity()).unitPrice(product.getPrice()).totalPrice(lineTotal)
                        .build());
                productService.decreaseStock(venue.getId().toString(), pr.getProductId(), pr.getQuantity());
            }
        }

        Booking booking = bookingRepository.save(Booking.builder()
                .user(user).court(court).venue(venue)
                .bookingDate(request.getBookingDate())
                .startTime(request.getStartTime()).endTime(request.getEndTime())
                .type(request.getType() != null ? request.getType() : BookingType.HOURLY)
                .status(BookingStatus.PENDING)
                .totalAmount(courtAmount.add(productsTotal))
                .notes(request.getNotes())
                .build());

        bookingProducts.forEach(bp -> bp.setBooking(booking));
        bookingProductRepository.saveAll(bookingProducts);
        booking.setProducts(bookingProducts);

        return bookingMapper.toResponse(booking);
    }

    @Transactional
    public BookingResponse confirmBooking(String bookingId, String venueManagerId) {
        Booking booking = findBooking(bookingId);
        User manager = findUser(venueManagerId);
        if (!booking.getVenue().getOwner().getId().equals(manager.getId()))
            throw new AppException(ErrorCode.UNAUTHORIZED);
        if (booking.getStatus() != BookingStatus.PENDING)
            throw new AppException(ErrorCode.BOOKING_CANNOT_CANCEL);
        booking.setStatus(BookingStatus.CONFIRMED);
        return bookingMapper.toResponse(bookingRepository.save(booking));
    }

    @Transactional
    public BookingResponse cancelBooking(String bookingId, String userId, String reason) {
        Booking booking = findBooking(bookingId);
        if (booking.getStatus() == BookingStatus.COMPLETED
                || booking.getStatus() == BookingStatus.IN_PROGRESS
                || booking.getStatus() == BookingStatus.CANCELLED) {
            throw new AppException(ErrorCode.BOOKING_CANNOT_CANCEL);
        }
        User user = findUser(userId);
        boolean isOwner = booking.getUser().getId().equals(user.getId());
        boolean isManager = booking.getVenue() != null
                && booking.getVenue().getOwner().getId().equals(user.getId());
        if (!isOwner && !isManager) throw new AppException(ErrorCode.UNAUTHORIZED);
        booking.setStatus(BookingStatus.CANCELLED);
        booking.setCancelReason(reason);
        return bookingMapper.toResponse(bookingRepository.save(booking));
    }

    @Transactional
    public BookingResponse completeBooking(String bookingId) {
        Booking booking = findBooking(bookingId);
        if (booking.getStatus() != BookingStatus.CONFIRMED && booking.getStatus() != BookingStatus.IN_PROGRESS)
            throw new AppException(ErrorCode.BOOKING_CANNOT_CANCEL);
        booking.setStatus(BookingStatus.COMPLETED);
        Booking saved = bookingRepository.save(booking);
        financeService.createFinanceRecord(saved);
        return bookingMapper.toResponse(saved);
    }

    public PageResponse<BookingResponse> getUserBookings(String userId, int page, int size) {
        User user = findUser(userId);
        Page<Booking> result = bookingRepository.findByUser(user,
                PageRequest.of(page - 1, size, Sort.by("createdAt").descending()));
        return buildPage(result, page, size);
    }

    public PageResponse<BookingResponse> getVenueBookings(String venueId, int page, int size) {
        Venue venue = findVenue(venueId);
        Page<Booking> result = bookingRepository.findByVenue(venue,
                PageRequest.of(page - 1, size, Sort.by("createdAt").descending()));
        return buildPage(result, page, size);
    }

    public Booking findBooking(String bookingId) {
        try {
            return bookingRepository.findById(UUID.fromString(bookingId))
                    .orElseThrow(() -> new AppException(ErrorCode.BOOKING_NOT_FOUND));
        } catch (IllegalArgumentException e) { throw new AppException(ErrorCode.ID_INVALID); }
    }

    private Venue findVenue(String venueId) {
        return venueRepository.findById(UUID.fromString(venueId))
                .orElseThrow(() -> new AppException(ErrorCode.VENUE_NOT_FOUND));
    }

    private User findUser(String userId) {
        return userRepository.findById(UUID.fromString(userId))
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
    }

    private PageResponse<BookingResponse> buildPage(Page<Booking> page, int pageNum, int size) {
        return PageResponse.<BookingResponse>builder()
                .items(page.getContent().stream().map(bookingMapper::toResponse).toList())
                .total(page.getTotalElements()).page(pageNum).pageSize(size).totalPages(page.getTotalPages())
                .build();
    }
}
