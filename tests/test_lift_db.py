"""Schema and business logic tests. Run: python tests/test_lift_db.py"""
import sqlite3
import unittest

from build_db import build

GULSHAN = (23.792500, 90.407800)


class LiftDbTest(unittest.TestCase):
    def setUp(self):
        self.conn = build()

    def tearDown(self):
        self.conn.close()

    def one(self, sql, params=()):
        return self.conn.execute(sql, params).fetchone()

    # schema and seed

    def test_seed_row_counts(self):
        for table, expected in [("app_user", 12), ("vehicle", 8), ("driver", 6),
                                ("rider", 6), ("trip", 17), ("payment", 12),
                                ("payout", 4), ("location", 8)]:
            n = self.one(f"SELECT COUNT(*) FROM {table}")[0]
            self.assertEqual(n, expected, table)

    def test_seed_fares_match_pricing_rule(self):
        rows = self.conn.execute("""
            SELECT t.trip_id, t.fare, v.base_rate + v.rate_per_km * t.distance_km
            FROM trip t JOIN vehicle v ON v.vehicle_id = t.vehicle_id
            WHERE t.status = 'completed'""").fetchall()
        self.assertEqual(len(rows), 12)
        for trip_id, fare, expected in rows:
            self.assertAlmostEqual(fare, expected, places=2, msg=f"trip {trip_id}")

    def test_payout_view_matches_seeded_settlement(self):
        # June payouts were computed by hand in 04_seed.sql. The view must agree.
        rows = dict(self.conn.execute("""
            SELECT COALESCE('c' || company_id, 's' || sharer_id), net_due
            FROM v_payout_due WHERE cycle = '2023-06'""").fetchall())
        self.assertAlmostEqual(rows["c1"], 260.80, places=2)
        self.assertAlmostEqual(rows["c2"], 631.72, places=2)
        self.assertAlmostEqual(rows["s1"], 247.52, places=2)
        self.assertAlmostEqual(rows["s2"], 454.80, places=2)

    # trip completion (fare calc + payment in one transaction)

    def test_complete_trip_flow(self):
        # trip 15 is in_progress on vehicle 1 (base 80, 32/km); 6 km ride
        with self.conn:
            self.conn.execute("""
                UPDATE trip
                SET end_time = '2023-07-28 09:31:00', distance_km = 6.0,
                    fare = (SELECT base_rate + rate_per_km * 6.0
                            FROM vehicle WHERE vehicle_id = trip.vehicle_id),
                    status = 'completed', rider_rating = 5, driver_rating = 4
                WHERE trip_id = 15 AND status = 'in_progress'""")
            self.conn.execute("""
                INSERT INTO payment (trip_id, amount, method, paid_at)
                SELECT 15, fare, 'cash', '2023-07-28 09:32:00' FROM trip
                WHERE trip_id = 15""")
        fare, paid = self.one("""
            SELECT t.fare, p.amount FROM trip t
            JOIN payment p ON p.trip_id = t.trip_id WHERE t.trip_id = 15""")
        self.assertAlmostEqual(fare, 80 + 32 * 6.0, places=2)
        self.assertAlmostEqual(paid, fare, places=2)

    def test_payment_rejected_when_amount_differs_from_fare(self):
        with self.assertRaisesRegex(sqlite3.IntegrityError, "must equal trip fare"):
            self.conn.execute("""
                INSERT INTO payment (trip_id, amount, method, paid_at)
                VALUES (1, 999.99, 'cash', '2023-06-05 09:00:00')""")

    def test_payment_rejected_for_open_trip(self):
        with self.assertRaisesRegex(sqlite3.IntegrityError, "completed trip"):
            self.conn.execute("""
                INSERT INTO payment (trip_id, amount, method, paid_at)
                VALUES (16, 100.00, 'cash', '2023-07-28 10:00:00')""")

    # driver assignment

    def test_nearest_free_driver_excludes_busy_ones(self):
        # Driver 1 is physically at Gulshan but on an in_progress trip and
        # driver 6 is assigned, so the pick must be driver 3 (Banani, next door).
        row = self.one("""
            SELECT dr.driver_id FROM driver dr
            JOIN location l ON l.loc_id = dr.current_loc_id
            WHERE dr.vehicle_id IS NOT NULL
              AND NOT EXISTS (SELECT 1 FROM trip t
                              WHERE t.driver_id = dr.driver_id
                                AND t.status IN ('assigned', 'in_progress'))
            ORDER BY (l.latitude - ?) * (l.latitude - ?)
                   + (l.longitude - ?) * (l.longitude - ?)
            LIMIT 1""", (GULSHAN[0], GULSHAN[0], GULSHAN[1], GULSHAN[1]))
        self.assertEqual(row[0], 3)

    # constraint spot checks

    def test_rating_above_five_rejected(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.conn.execute("UPDATE trip SET rider_rating = 6 WHERE trip_id = 1")

    def test_negative_fare_rejected(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.conn.execute("UPDATE trip SET fare = -5 WHERE trip_id = 1")

    def test_vehicle_cannot_have_two_owners(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.conn.execute("""
                INSERT INTO vehicle VALUES (99, 'DHK-XX-9999', 'Test', 'Test',
                    'sedan', 50, 20, 'company', 1, 1, 1)""")

    def test_duplicate_payment_for_trip_rejected(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.conn.execute("""
                INSERT INTO payment (trip_id, amount, method, paid_at)
                VALUES (1, 320.00, 'cash', '2023-06-05 09:00:00')""")


if __name__ == "__main__":
    unittest.main(verbosity=2)
