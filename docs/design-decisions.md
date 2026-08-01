# Design decisions

Notes on the calls that shaped this schema, including the ones I rejected.

## One vehicle table instead of three

The original schema had company_vehicle, garage_vehicle, and sharer_vehicle, each repeating the same six columns and differing only in which FK they carried. Every fleet query had to UNION three tables, and trip could not have a clean vehicle FK at all (the old DDL pointed it at a table that did not exist).

Now there is one vehicle table with an owner_type discriminator and two nullable FKs, plus a CHECK that exactly the right FK is set for each owner type. Trips, drivers, and analytics all join one table.

Rejected: subtype tables (vehicle plus company_vehicle_ext etc). Correct in theory, but the subtypes have no extra attributes here, so the extra join buys nothing.

Rejected: a single owner_id column without separate FKs. Loses referential integrity, the database can no longer guarantee the owner exists.

The same discriminator pattern is applied to bank_account (user or company money) and payout (company or sharer payee), which used to be duplicated table pairs.

## Batched payouts, not per-trip transfers

Riders pay per trip, but LIFT settles with vehicle owners once per cycle (the seed uses monthly). Reasons:

- Transfer fees and reconciliation overhead scale with transfer count. Hundreds of trips per owner per month collapse into one transfer.
- Disputes and refunds within the cycle can be netted before money moves.
- The payout table then stores an auditable statement per cycle, and v_payout_due recomputes what the cycle should have been. If the two disagree you have found a bug or a dispute.

Rejected: paying owners per trip in the payment table. It mixes rider money-in with owner money-out in one table, and makes commission changes retroactively ambiguous.

## Fare stored on the trip, amount stored on the payment

Denormalized on purpose. The fare is what the pricing rule produced when the trip closed. The payment is evidence of money received and must stay immutable even if pricing logic changes later. A trigger enforces amount = fare at insert time, so the duplication cannot drift silently.

## Derived data is not stored

sharer_age is gone (derivable from dob). Driver employer is gone (derivable from vehicle ownership). The old map table is folded into location: a separate table keyed by mapgrid_id holding only lat/long was a 1:1 indirection that added a join and nothing else.

## Trip keeps both driver_id and vehicle_id

Today a driver has exactly one vehicle, so storing both looks redundant. But assignments change over months, and a trip is a historical fact: it must record the vehicle that actually drove it. This is temporal accuracy, not a normalization failure.

## SQLite as the reference backend

The old DDL (kept as written in lift.sql) targeted Oracle and had never been run (it could not run, it referenced missing tables and used invalid NUMBER precisions). I wanted a backend anyone can execute with zero install, so the repo is tested against SQLite with types kept Oracle friendly. The costs, accepted consciously:

- No stored procedures, so trip completion ships as a transaction template (queries/complete_trip.sql) instead of a procedure. On Oracle or Postgres it should become one.
- Constraints must be declared with the tables, so 02_constraints.sql carries the uniqueness indexes and cross-table triggers rather than ALTER TABLE ADD CONSTRAINT statements.
- No docker-compose: a serverless file database needs no container. `python tests/build_db.py` is the whole setup.
