-- Revenue split per completed trip. For LIFT owned vehicles the whole
-- fare stays with LIFT. For company and sharer vehicles LIFT keeps the
-- commission and owes the rest to the owner.
CREATE VIEW v_trip_earnings AS
SELECT
    t.trip_id,
    t.end_time,
    v.owner_type,
    v.company_id,
    v.sharer_id,
    t.fare                                            AS gross_fare,
    CASE v.owner_type
        WHEN 'lift'    THEN t.fare
        WHEN 'company' THEN ROUND(t.fare * c.commission_pct / 100.0, 2)
        WHEN 'sharer'  THEN ROUND(t.fare * s.commission_pct / 100.0, 2)
    END                                               AS lift_share,
    CASE v.owner_type
        WHEN 'lift'    THEN 0
        WHEN 'company' THEN ROUND(t.fare - t.fare * c.commission_pct / 100.0, 2)
        WHEN 'sharer'  THEN ROUND(t.fare - t.fare * s.commission_pct / 100.0, 2)
    END                                               AS owner_net
FROM trip t
JOIN vehicle v      ON v.vehicle_id = t.vehicle_id
LEFT JOIN company c     ON c.company_id = v.company_id
LEFT JOIN ride_sharer s ON s.sharer_id  = v.sharer_id
WHERE t.status = 'completed';

-- What LIFT owes each company and sharer per monthly cycle.
-- Compare against the payout table to see what is settled and what is due.
CREATE VIEW v_payout_due AS
SELECT
    v.owner_type                       AS payee_type,
    v.company_id,
    v.sharer_id,
    strftime('%Y-%m', v.end_time)      AS cycle,
    COUNT(*)                           AS trips,
    SUM(v.gross_fare)                  AS gross_total,
    SUM(v.owner_net)                   AS net_due
FROM v_trip_earnings v
WHERE v.owner_type <> 'lift'
GROUP BY v.owner_type, v.company_id, v.sharer_id, strftime('%Y-%m', v.end_time);
