# LIFT

A relational database for a ride-sharing company with a mixed fleet: LIFT owns some vehicles, hires others from sub-companies, and takes personal cars from individual ride sharers. Riders pay per trip, but vehicle owners are settled in batched payout cycles where LIFT keeps a commission. The schema models the whole loop: booking, driver assignment, trip lifecycle, payment, and settlement.

Everything runs and is tested against SQLite, no server or install needed. Types are kept Oracle friendly since that is where the project started.

## Data model

The original ER diagram, drawn in Chen notation when this database was first designed:

![Original ER diagram](ER.jpeg)

The implemented schema follows it, with a few consolidations made along the way (one vehicle table instead of three, the map grid folded into location):

```mermaid
erDiagram
    app_user ||--o| rider : "can be"
    app_user ||--o| driver : "can be"
    app_user ||--o| ride_sharer : "can be"
    app_user ||--o{ bank_account : holds
    company ||--o{ bank_account : holds
    company ||--o{ vehicle : owns
    ride_sharer ||--o{ vehicle : owns
    garage ||--o{ vehicle : parks
    driver |o--|| vehicle : drives
    rider ||--o{ trip : books
    driver ||--o{ trip : serves
    vehicle ||--o{ trip : runs
    location ||--o{ trip : "start / end"
    trip ||--o| payment : "paid by"
    rider }o--o{ offer : "holds via rider_offer"
    company ||--o{ payout : receives
    ride_sharer ||--o{ payout : receives

    vehicle {
        int vehicle_id PK
        string owner_type "lift | company | sharer"
        number base_rate
        number rate_per_km
    }
    trip {
        int trip_id PK
        string status "requested .. completed"
        number distance_km
        number fare
        int rider_rating "1..5"
        int driver_rating "1..5"
    }
    payout {
        int payout_id PK
        string payee_type "company | sharer"
        date period_start
        date period_end
        number amount
    }
```

The three vehicle ownership paths live in one `vehicle` table with an `owner_type` discriminator and CHECK constraints, not three parallel tables. Same pattern for `bank_account` and `payout`. Reasoning in [docs/design-decisions.md](docs/design-decisions.md).

## A trip, end to end

```mermaid
sequenceDiagram
    participant R as Rider
    participant DB as Database
    participant D as Driver
    participant O as Vehicle owner

    R->>DB: book trip (status requested)
    DB->>DB: nearest free driver query
    DB->>D: assign (status assigned)
    D->>DB: start trip (in_progress)
    D->>DB: end trip: fare = base_rate + rate_per_km * km
    Note over DB: one transaction closes the trip,<br/>stores ratings, inserts payment
    R->>DB: pay fare (trigger checks amount = fare)
    DB->>O: monthly payout cycle, fare minus commission
```

## Run it

```bash
python tests/build_db.py lift.db     # build a seeded database
python tests/test_lift_db.py         # run the test suite (11 tests)
sqlite3 lift.db < queries/analytics.sql   # optional, needs sqlite3 CLI
```

The tests cover the fare calculation, the trip completion transaction, nearest-free-driver assignment, and the constraints (ratings 1 to 5, positive fares, single owner per vehicle, payment must match fare).

## Layout

| Path | What |
|---|---|
| `schema/01_tables.sql` | Tables with FK and CHECK constraints |
| `schema/02_constraints.sql` | Uniqueness rules and integrity triggers |
| `schema/03_indexes.sql` | FK and access-path indexes |
| `schema/04_seed.sql` | Deterministic sample data (fares follow the pricing rule) |
| `schema/05_views.sql` | Earnings split and payout-due views |
| `queries/analytics.sql` | 10 operational queries: payouts per cycle, driver utilization, peak hours, zones, rider LTV, driver quality |
| `queries/complete_trip.sql` | Trip completion as one atomic transaction |
| `tests/` | Build script and test suite (stdlib only) |
| `docs/` | [requirements](docs/requirements.md), [schema reference](docs/schema.md), [design decisions](docs/design-decisions.md), [scaling notes](docs/scaling.md) |
| `lift.sql` | The original DDL from December 2022, kept exactly as we wrote it back then |
| `Scenario.docx` | The original scenario document from 2022 ([docs/requirements.md](docs/requirements.md) is its markdown conversion) |

## What this models well, and what it does not

Models well: fleet ownership variants, the trip lifecycle with status-dependent constraints, money in (per-trip payments) vs money out (batched commissions), and enough integrity rules that bad states are unrepresentable rather than merely discouraged.

Does not model: real geospatial search, surge pricing, driver shifts, or refunds. The first of those is discussed honestly in [docs/scaling.md](docs/scaling.md).
