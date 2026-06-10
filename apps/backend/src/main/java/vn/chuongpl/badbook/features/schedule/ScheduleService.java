package vn.chuongpl.badbook.features.schedule;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.chuongpl.badbook.common.enums.*;
import vn.chuongpl.badbook.common.exception.AppException;
import vn.chuongpl.badbook.features.booking.Booking;
import vn.chuongpl.badbook.features.booking.BookingRepository;
import vn.chuongpl.badbook.features.court.Court;
import vn.chuongpl.badbook.features.court.CourtService;
import vn.chuongpl.badbook.features.schedule.dto.FixedScheduleCreateRequest;
import vn.chuongpl.badbook.features.user.User;
import vn.chuongpl.badbook.features.user.UserRepository;
import vn.chuongpl.badbook.features.venue.Venue;
import vn.chuongpl.badbook.features.venue.VenueRepository;

import java.math.BigDecimal;
import java.time.*;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Slf4j
public class ScheduleService {

    FixedScheduleRepository scheduleRepository;
    BookingRepository bookingRepository;
    UserRepository userRepository;
    VenueRepository venueRepository;
    CourtService courtService;

    @Transactional
    public FixedSchedule createSchedule(String userId, FixedScheduleCreateRequest request) {
        User user = userRepository.findById(UUID.fromString(userId))
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
        Venue venue = venueRepository.findById(UUID.fromString(request.getVenueId()))
                .orElseThrow(() -> new AppException(ErrorCode.VENUE_NOT_FOUND));
        Court court = courtService.findCourt(request.getCourtId());

        if (!court.getVenue().getId().equals(venue.getId()))
            throw new AppException(ErrorCode.COURT_NOT_IN_VENUE);

        FixedSchedule schedule = FixedSchedule.builder()
                .user(user).court(court).venue(venue)
                .daysOfWeek(String.join(",", request.getDaysOfWeek()))
                .startTime(request.getStartTime()).endTime(request.getEndTime())
                .startDate(request.getStartDate()).endDate(request.getEndDate())
                .notes(request.getNotes()).status("ACTIVE").build();
        return scheduleRepository.save(schedule);
    }

    @Scheduled(cron = "0 0 6 * * MON")
    @Transactional
    public void generateWeeklyBookings() {
        log.info("Generating weekly bookings from fixed schedules");
        LocalDate weekStart = LocalDate.now();
        generateBookingsForWeek(weekStart);
    }

    @Transactional
    public void generateBookingsForWeek(LocalDate weekStart) {
        List<FixedSchedule> active = scheduleRepository.findByStatus("ACTIVE");
        LocalDate weekEnd = weekStart.plusDays(6);

        for (FixedSchedule schedule : active) {
            if (schedule.getEndDate().isBefore(weekStart)) continue;

            List<String> days = Arrays.asList(schedule.getDaysOfWeek().split(","));
            for (LocalDate date = weekStart; !date.isAfter(weekEnd); date = date.plusDays(1)) {
                if (!days.contains(date.getDayOfWeek().toString().substring(0, 3))) continue;
                if (date.isBefore(schedule.getStartDate()) || date.isAfter(schedule.getEndDate())) continue;

                boolean conflict = bookingRepository.existsConflict(
                        schedule.getCourt(), date, schedule.getStartTime(), schedule.getEndTime());
                if (conflict) { log.warn("Conflict on {} for schedule {}", date, schedule.getId()); continue; }

                long hours = Duration.between(schedule.getStartTime(), schedule.getEndTime()).toHours();
                BigDecimal total = schedule.getCourt().getPricePerHour().multiply(BigDecimal.valueOf(hours));

                bookingRepository.save(Booking.builder()
                        .user(schedule.getUser()).court(schedule.getCourt()).venue(schedule.getVenue())
                        .bookingDate(date).startTime(schedule.getStartTime()).endTime(schedule.getEndTime())
                        .type(BookingType.FIXED).status(BookingStatus.CONFIRMED)
                        .totalAmount(total).notes("Lịch cố định: " + schedule.getId()).build());
            }
        }
    }

    public List<FixedSchedule> getUserSchedules(String userId) {
        User user = userRepository.findById(UUID.fromString(userId))
                .orElseThrow(() -> new AppException(ErrorCode.ACCOUNT_NOT_FOUND));
        return scheduleRepository.findByUserAndStatus(user, "ACTIVE");
    }

    @Transactional
    public void cancelSchedule(String scheduleId, String userId) {
        FixedSchedule schedule = scheduleRepository.findById(UUID.fromString(scheduleId))
                .orElseThrow(() -> new AppException(ErrorCode.SCHEDULE_NOT_FOUND));
        if (!schedule.getUser().getId().toString().equals(userId))
            throw new AppException(ErrorCode.UNAUTHORIZED);
        schedule.setStatus("CANCELLED");
        scheduleRepository.save(schedule);
    }
}
