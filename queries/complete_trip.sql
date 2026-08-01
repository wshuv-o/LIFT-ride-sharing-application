-- Trip completion is one atomic unit: close the trip with fare and
-- ratings, then record the payment. If any statement fails the whole
-- thing rolls back and the trip stays open.
--
-- On Oracle or Postgres this would be a stored procedure. SQLite has no
-- procedures, so it ships as a transaction template. The fare rule is
--   fare = vehicle.base_rate + vehicle.rate_per_km * distance_km
-- and the payment trigger rejects any amount that does not match.
--
-- Example: complete the in_progress trip 15 (vehicle 1: 80 + 32/km),
-- rider went 6.0 km, so the fare is 272.00.

BEGIN;

UPDATE trip
SET end_time      = '2023-07-28 09:31:00',
    distance_km   = 6.0,
    fare          = (SELECT v.base_rate + v.rate_per_km * 6.0
                     FROM vehicle v WHERE v.vehicle_id = trip.vehicle_id),
    status        = 'completed',
    rider_rating  = 5,
    driver_rating = 4
WHERE trip_id = 15
  AND status = 'in_progress';

INSERT INTO payment (payment_id, trip_id, amount, method, paid_at, account_no)
SELECT NULL, 15, fare, 'cash', '2023-07-28 09:32:00', NULL
FROM trip WHERE trip_id = 15;

COMMIT;
