-- Business rule constraints that SQLite cannot express inline:
-- uniqueness as named indexes, cross table rules as triggers.

-- One account per person/company pairing is fine, but identities must be unique.
CREATE UNIQUE INDEX ux_user_email        ON app_user (email);
CREATE UNIQUE INDEX ux_user_phone        ON app_user (phone);
CREATE UNIQUE INDEX ux_company_name      ON company (name);
CREATE UNIQUE INDEX ux_vehicle_reg       ON vehicle (reg_no);
CREATE UNIQUE INDEX ux_driver_license    ON driver (license_no);

-- A user holds at most one rider profile, one sharer profile, one driver profile.
CREATE UNIQUE INDEX ux_rider_user        ON rider (user_id);
CREATE UNIQUE INDEX ux_sharer_user       ON ride_sharer (user_id);
CREATE UNIQUE INDEX ux_driver_user       ON driver (user_id);

-- Each driver drives exactly one vehicle and each vehicle has one driver.
CREATE UNIQUE INDEX ux_driver_vehicle    ON driver (vehicle_id);

-- A trip is paid at most once.
CREATE UNIQUE INDEX ux_payment_trip      ON payment (trip_id);

-- Payments only exist for completed trips.
CREATE TRIGGER trg_payment_needs_completed_trip
BEFORE INSERT ON payment
FOR EACH ROW
WHEN (SELECT status FROM trip WHERE trip_id = NEW.trip_id) <> 'completed'
BEGIN
    SELECT RAISE(ABORT, 'payment requires a completed trip');
END;

-- The paid amount must match the fare stored on the trip.
CREATE TRIGGER trg_payment_matches_fare
BEFORE INSERT ON payment
FOR EACH ROW
WHEN NEW.amount <> (SELECT fare FROM trip WHERE trip_id = NEW.trip_id)
BEGIN
    SELECT RAISE(ABORT, 'payment amount must equal trip fare');
END;
