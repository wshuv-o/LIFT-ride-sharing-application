-- Performance indexes. Every FK that gets joined or filtered on,
-- plus the two hottest trip access paths (by rider, by time).

CREATE INDEX ix_sharer_user       ON ride_sharer (user_id);

CREATE INDEX ix_vehicle_company   ON vehicle (company_id);
CREATE INDEX ix_vehicle_sharer    ON vehicle (sharer_id);
CREATE INDEX ix_vehicle_garage    ON vehicle (garage_id);

CREATE INDEX ix_driver_location   ON driver (current_loc_id);

CREATE INDEX ix_trip_rider        ON trip (rider_id);
CREATE INDEX ix_trip_driver       ON trip (driver_id);
CREATE INDEX ix_trip_vehicle      ON trip (vehicle_id);
CREATE INDEX ix_trip_start_loc    ON trip (start_loc_id);
CREATE INDEX ix_trip_end_loc      ON trip (end_loc_id);
CREATE INDEX ix_trip_start_time   ON trip (start_time);
CREATE INDEX ix_trip_status       ON trip (status);

CREATE INDEX ix_payment_account   ON payment (account_no);
CREATE INDEX ix_payment_paid_at   ON payment (paid_at);

CREATE INDEX ix_account_user      ON bank_account (user_id);
CREATE INDEX ix_account_company   ON bank_account (company_id);

CREATE INDEX ix_rider_offer_offer ON rider_offer (offer_id);

CREATE INDEX ix_payout_company    ON payout (company_id);
CREATE INDEX ix_payout_sharer     ON payout (sharer_id);
CREATE INDEX ix_payout_period     ON payout (period_start, period_end);
