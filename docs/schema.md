# Schema reference

Fourteen tables, two views. Types stay close to Oracle conventions (NUMBER, VARCHAR, DATE, TIMESTAMP), which SQLite accepts as is.

## Tables

| Table | Purpose | Key relationships |
|---|---|---|
| app_user | One row per person on the platform. Riders, drivers, and sharers all reference this. | referenced by rider, driver, ride_sharer, bank_account |
| company | Sub-company whose vehicles run under LIFT, with its commission percentage. | referenced by vehicle, bank_account, payout |
| ride_sharer | A user who plugs a personal vehicle into the fleet. Carries their commission rate. | user_id -> app_user (1:1) |
| garage | LIFT's parking garages. | referenced by vehicle |
| vehicle | The whole fleet in one table. owner_type says whether LIFT, a company, or a sharer owns it. | company_id or sharer_id set per owner_type, garage_id -> garage |
| location | A named point with zip code and coordinates. | referenced by driver and trip |
| driver | A user licensed to drive, assigned to exactly one vehicle, with a last known location. | user_id -> app_user (1:1), vehicle_id unique |
| rider | A user who books trips, with a loyalty tier. | user_id -> app_user (1:1) |
| trip | The core fact table. One row per booking, through its whole lifecycle. | rider 1:N, driver 1:N, vehicle 1:N, two location FKs |
| bank_account | Accounts held by users or by companies, discriminated by owner_type. | user_id or company_id per owner_type |
| payment | Rider's payment for one completed trip. Exactly one per trip. | trip_id unique -> trip |
| offer | Discount definitions. | referenced by rider_offer |
| rider_offer | Which rider holds which offer (M:N resolver). | composite PK (rider_id, offer_id) |
| payout | One batched settlement per payee per cycle. | company_id or sharer_id per payee_type |

## Views

| View | Purpose |
|---|---|
| v_trip_earnings | Per completed trip: gross fare, LIFT's cut, owner's net, based on the owner's commission rate. |
| v_payout_due | Monthly aggregation of owner_net per company/sharer. Compare with payout to see what is settled. |

## Cardinalities

- app_user 1:1 rider, 1:1 driver, 1:1 ride_sharer (a user can hold several roles, each at most once)
- app_user 1:N bank_account, company 1:N bank_account
- company 1:N vehicle, ride_sharer 1:N vehicle, garage 1:N vehicle
- driver 1:1 vehicle (unique index both ways: one driver per vehicle, one vehicle per driver)
- rider 1:N trip, driver 1:N trip, vehicle 1:N trip, location 1:N trip (as start and as end)
- trip 1:1 payment (unique index on payment.trip_id)
- rider M:N offer through rider_offer
- company 1:N payout, ride_sharer 1:N payout

## Normalization

The schema is in third normal form:

- 1NF: all attributes atomic, no repeating groups (the old schema kept three copies of the vehicle columns, one per owner type; that is gone).
- 2NF: every table has a single-column surrogate key except rider_offer, whose non-key attribute (granted_at) depends on the full composite key.
- 3NF: no transitive dependencies on non-key attributes. Two removals worth naming: sharer_age was dropped because age is derivable from app_user.dob, and driver does not store an employer column because the employer follows from the owner of the vehicle the driver is assigned to.

Two deliberate softenings, both documented in design-decisions.md: trip carries vehicle_id even though today's driver implies today's vehicle (assignments change over time, a trip must record what actually drove it), and payment.amount duplicates trip.fare (a payment must be immutable evidence of what was charged; a trigger keeps them equal at insert time).
