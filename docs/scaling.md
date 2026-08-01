# What breaks at 1M trips a day

This schema is honest about being a single-node design. Here is where it cracks under real load and what I would change.

## The trip table becomes the bottleneck

1M trips/day is about 365M rows/year in trip, with payment matching it row for row. Single-table indexes on that volume make every insert pay for six index updates, and the b-trees stop fitting in memory.

Fix: range partition trip and payment by time (daily or monthly partitions). Old partitions become read-only, get aggregated into summary tables, then archived. Postgres declarative partitioning or Oracle interval partitioning both handle this. The analytics in queries/analytics.sql should run against rollups, not the raw table.

## Reads and writes fight each other

Dispatch (find free driver, book, update status) is write-heavy and latency-sensitive. Analytics (payouts, utilization, LTV) is read-heavy and latency-tolerant. On one node the monthly payout scan evicts the dispatch working set.

Fix: read replicas for analytics and reporting, primary reserved for the booking path. Payout jobs run on a replica with relaxed freshness; the settlement is only cut once per cycle anyway.

## Driver location updates are a firehose

Every active driver pings a location every few seconds. Writing that into driver.current_loc_id via a location row per ping would melt the table and bloat location with billions of throwaway points.

Fix: driver presence lives in an in-memory store (Redis with geospatial commands, or an in-process grid), and only trip-relevant snapshots (pickup point, dropoff point) are persisted to the database. The relational store keeps facts, not telemetry.

## Nearest-driver search needs real geo indexing

The assignment query here orders free drivers by squared coordinate deltas. Fine for eight seeded locations, useless at city scale: it is a full scan per request, and degree deltas distort distance away from the equator.

Fix: either PostGIS (GiST index on a geography column, ST_DWithin for radius search, KNN operator for ordering) or a geohash/H3 cell scheme where drivers are bucketed by cell and a booking only scans its own cell plus neighbors. This is why the old map-grid table was not kept: a hand-rolled grid without index support gives the complexity of geohashing with none of the benefit.

## Payout math should not be recomputed from raw trips forever

v_payout_due aggregates every completed trip for an owner each time it runs. At scale, cycle totals should be accumulated incrementally (per-day owner rollups, summed at cycle close), with the raw trips kept as the audit trail.

## Sequence and contention details

- Surrogate integer keys are fine, but at high insert rates use cached sequences (Oracle) or identity with a generous cache (Postgres) to avoid sequence contention.
- The one-payment-per-trip unique index doubles as the idempotency guard when payment processing retries.
- The status column plus partial indexes (WHERE status IN ('assigned','in_progress')) keeps the dispatch scan bounded by active trips, not total trips.
