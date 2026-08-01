-- Analytics queries against the seeded database. Run any of them with
--   sqlite3 lift.db < queries/analytics.sql
-- or paste them one at a time.

-- 1. Payout owed per company/sharer per monthly cycle, and whether a
--    payout row already covers it.
SELECT
    d.cycle,
    d.payee_type,
    COALESCE(c.name, u.first_name || ' ' || u.last_name) AS payee,
    d.trips,
    d.gross_total,
    d.net_due,
    CASE WHEN p.payout_id IS NULL THEN 'due' ELSE 'settled' END AS state
FROM v_payout_due d
LEFT JOIN company c      ON c.company_id = d.company_id
LEFT JOIN ride_sharer rs ON rs.sharer_id = d.sharer_id
LEFT JOIN app_user u     ON u.user_id = rs.user_id
LEFT JOIN payout p
       ON p.payee_type = d.payee_type
      AND (p.company_id = d.company_id OR p.sharer_id = d.sharer_id)
      AND strftime('%Y-%m', p.period_start) = d.cycle
ORDER BY d.cycle, d.payee_type, payee;

-- 2. Driver utilization: completed trips, hours on trips, earnings driven.
SELECT
    dr.driver_id,
    u.first_name || ' ' || u.last_name                    AS driver,
    COUNT(t.trip_id)                                      AS completed_trips,
    ROUND(SUM((julianday(t.end_time) - julianday(t.start_time)) * 24), 2) AS hours_driven,
    SUM(t.fare)                                           AS gross_earned
FROM driver dr
JOIN app_user u ON u.user_id = dr.user_id
LEFT JOIN trip t ON t.driver_id = dr.driver_id AND t.status = 'completed'
GROUP BY dr.driver_id, driver
ORDER BY gross_earned DESC;

-- 3. Peak hour demand: trip requests by hour of day.
SELECT
    strftime('%H', requested_at) AS hour_of_day,
    COUNT(*)                     AS requests
FROM trip
GROUP BY hour_of_day
ORDER BY requests DESC, hour_of_day;

-- 4. Demand by zone: where do trips start?
SELECT
    l.area_name,
    l.zip_code,
    COUNT(*) AS trips_started
FROM trip t
JOIN location l ON l.loc_id = t.start_loc_id
GROUP BY l.loc_id
ORDER BY trips_started DESC;

-- 5. Rider lifetime value: spend, trip count, average fare per rider.
SELECT
    r.rider_id,
    u.first_name || ' ' || u.last_name AS rider,
    r.tier,
    COUNT(t.trip_id)                   AS trips,
    COALESCE(SUM(t.fare), 0)           AS lifetime_spend,
    ROUND(COALESCE(AVG(t.fare), 0), 2) AS avg_fare
FROM rider r
JOIN app_user u ON u.user_id = r.user_id
LEFT JOIN trip t ON t.rider_id = r.rider_id AND t.status = 'completed'
GROUP BY r.rider_id, rider, r.tier
ORDER BY lifetime_spend DESC;

-- 6. Driver quality: average rating received, flag anyone under 4.
SELECT
    dr.driver_id,
    u.first_name || ' ' || u.last_name    AS driver,
    ROUND(AVG(t.driver_rating), 2)        AS avg_rating,
    COUNT(t.driver_rating)                AS ratings,
    CASE WHEN AVG(t.driver_rating) < 4 THEN 'review' ELSE 'ok' END AS flag
FROM driver dr
JOIN app_user u ON u.user_id = dr.user_id
JOIN trip t ON t.driver_id = dr.driver_id AND t.driver_rating IS NOT NULL
GROUP BY dr.driver_id, driver
ORDER BY avg_rating;

-- 7. Revenue split by fleet segment: how much does each ownership model bring in?
SELECT
    owner_type,
    COUNT(*)         AS trips,
    SUM(gross_fare)  AS gross,
    SUM(lift_share)  AS lift_keeps,
    SUM(owner_net)   AS paid_out_to_owners
FROM v_trip_earnings
GROUP BY owner_type
ORDER BY gross DESC;

-- 8. Cancellation rate by rider tier.
SELECT
    r.tier,
    COUNT(*)                                                        AS total_trips,
    SUM(CASE WHEN t.status = 'cancelled' THEN 1 ELSE 0 END)          AS cancelled,
    ROUND(100.0 * SUM(CASE WHEN t.status = 'cancelled' THEN 1 ELSE 0 END) / COUNT(*), 1) AS cancel_pct
FROM trip t
JOIN rider r ON r.rider_id = t.rider_id
GROUP BY r.tier
ORDER BY cancel_pct DESC;

-- 9. Fleet earnings per vehicle, with owner attribution.
SELECT
    v.vehicle_id,
    v.reg_no,
    v.owner_type,
    COALESCE(c.name, us.first_name || ' ' || us.last_name, 'LIFT') AS owner,
    COUNT(t.trip_id)          AS trips,
    COALESCE(SUM(t.fare), 0)  AS gross
FROM vehicle v
LEFT JOIN company c      ON c.company_id = v.company_id
LEFT JOIN ride_sharer rs ON rs.sharer_id = v.sharer_id
LEFT JOIN app_user us    ON us.user_id = rs.user_id
LEFT JOIN trip t ON t.vehicle_id = v.vehicle_id AND t.status = 'completed'
GROUP BY v.vehicle_id
ORDER BY gross DESC;

-- 10. Nearest free driver to a pickup point (driver assignment).
--     Free means their vehicle is not on an assigned or in_progress trip.
--     Distance here is a squared degree delta, good enough at city scale;
--     see docs/scaling.md for why real geo search needs more than this.
SELECT
    dr.driver_id,
    u.first_name || ' ' || u.last_name AS driver,
    l.area_name                        AS currently_at
FROM driver dr
JOIN app_user u  ON u.user_id = dr.user_id
JOIN location l  ON l.loc_id = dr.current_loc_id
WHERE dr.vehicle_id IS NOT NULL
  AND NOT EXISTS (
        SELECT 1 FROM trip t
        WHERE t.driver_id = dr.driver_id
          AND t.status IN ('assigned', 'in_progress'))
ORDER BY (l.latitude  - 23.792500) * (l.latitude  - 23.792500)
       + (l.longitude - 90.407800) * (l.longitude - 90.407800)
LIMIT 1;
