-- LIFT ride sharing schema
-- Dialect: SQLite (types chosen to stay Oracle friendly).
-- SQLite requires FK and CHECK constraints at table creation time,
-- so they live here. Business rule indexes and triggers are in
-- 02_constraints.sql, performance indexes in 03_indexes.sql.

CREATE TABLE app_user (
    user_id     INTEGER PRIMARY KEY,
    first_name  VARCHAR(30) NOT NULL,
    last_name   VARCHAR(30) NOT NULL,
    email       VARCHAR(80) NOT NULL,
    phone       VARCHAR(15) NOT NULL,
    dob         DATE,
    gender      VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
    address     VARCHAR(120)
);

CREATE TABLE company (
    company_id      INTEGER PRIMARY KEY,
    name            VARCHAR(60) NOT NULL,
    address         VARCHAR(120),
    commission_pct  NUMBER(5,2) NOT NULL DEFAULT 20.00
                    CHECK (commission_pct BETWEEN 0 AND 100)
);

-- A ride sharer is a user who plugs their own vehicle into the fleet.
-- No age column: it is derivable from app_user.dob.
CREATE TABLE ride_sharer (
    sharer_id       INTEGER PRIMARY KEY,
    user_id         INTEGER NOT NULL REFERENCES app_user (user_id),
    commission_pct  NUMBER(5,2) NOT NULL DEFAULT 20.00
                    CHECK (commission_pct BETWEEN 0 AND 100)
);

CREATE TABLE garage (
    garage_id  INTEGER PRIMARY KEY,
    name       VARCHAR(60) NOT NULL,
    address    VARCHAR(120)
);

-- One table for all vehicles. owner_type says whose it is:
--   lift     owned by LIFT itself, no owner FK set
--   company  owned by a sub company, company_id set
--   sharer   owned by a ride sharer, sharer_id set
CREATE TABLE vehicle (
    vehicle_id   INTEGER PRIMARY KEY,
    reg_no       VARCHAR(20) NOT NULL,
    model        VARCHAR(40) NOT NULL,
    brand        VARCHAR(30),
    vehicle_type VARCHAR(15) NOT NULL
                 CHECK (vehicle_type IN ('micro', 'subcompact', 'sedan', 'minivan', 'suv', 'bike')),
    base_rate    NUMBER(10,2) NOT NULL CHECK (base_rate > 0),
    rate_per_km  NUMBER(10,2) NOT NULL CHECK (rate_per_km > 0),
    owner_type   VARCHAR(10) NOT NULL CHECK (owner_type IN ('lift', 'company', 'sharer')),
    company_id   INTEGER REFERENCES company (company_id),
    sharer_id    INTEGER REFERENCES ride_sharer (sharer_id),
    garage_id    INTEGER NOT NULL REFERENCES garage (garage_id),
    CHECK (
        (owner_type = 'lift'    AND company_id IS NULL     AND sharer_id IS NULL) OR
        (owner_type = 'company' AND company_id IS NOT NULL AND sharer_id IS NULL) OR
        (owner_type = 'sharer'  AND sharer_id  IS NOT NULL AND company_id IS NULL)
    )
);

CREATE TABLE location (
    loc_id     INTEGER PRIMARY KEY,
    zip_code   VARCHAR(10),
    area_name  VARCHAR(60),
    latitude   NUMBER(9,6) NOT NULL CHECK (latitude  BETWEEN -90  AND 90),
    longitude  NUMBER(9,6) NOT NULL CHECK (longitude BETWEEN -180 AND 180)
);

-- Every driver is a user. Employer is derivable from the vehicle they
-- drive (vehicle.owner_type), so it is not repeated here.
CREATE TABLE driver (
    driver_id       INTEGER PRIMARY KEY,
    user_id         INTEGER NOT NULL REFERENCES app_user (user_id),
    license_no      VARCHAR(20) NOT NULL,
    vehicle_id      INTEGER REFERENCES vehicle (vehicle_id),
    current_loc_id  INTEGER REFERENCES location (loc_id)
);

CREATE TABLE rider (
    rider_id  INTEGER PRIMARY KEY,
    user_id   INTEGER NOT NULL REFERENCES app_user (user_id),
    tier      VARCHAR(10) NOT NULL DEFAULT 'bronze'
              CHECK (tier IN ('bronze', 'silver', 'gold'))
);

CREATE TABLE trip (
    trip_id       INTEGER PRIMARY KEY,
    rider_id      INTEGER NOT NULL REFERENCES rider (rider_id),
    -- driver and vehicle are unknown while the trip is still 'requested'
    driver_id     INTEGER REFERENCES driver (driver_id),
    vehicle_id    INTEGER REFERENCES vehicle (vehicle_id),
    start_loc_id  INTEGER NOT NULL REFERENCES location (loc_id),
    end_loc_id    INTEGER REFERENCES location (loc_id),
    requested_at  TIMESTAMP NOT NULL,
    start_time    TIMESTAMP,
    end_time      TIMESTAMP,
    distance_km   NUMBER(6,2) CHECK (distance_km > 0),
    fare          NUMBER(10,2) CHECK (fare > 0),
    status        VARCHAR(12) NOT NULL DEFAULT 'requested'
                  CHECK (status IN ('requested', 'assigned', 'in_progress', 'completed', 'cancelled')),
    rider_rating  NUMBER(1) CHECK (rider_rating  BETWEEN 1 AND 5),
    driver_rating NUMBER(1) CHECK (driver_rating BETWEEN 1 AND 5),
    CHECK (end_time IS NULL OR start_time IS NOT NULL),
    CHECK (status IN ('requested', 'cancelled')
           OR (driver_id IS NOT NULL AND vehicle_id IS NOT NULL)),
    CHECK (status <> 'completed' OR (fare IS NOT NULL AND end_time IS NOT NULL)),
    CHECK (rider_rating  IS NULL OR status = 'completed'),
    CHECK (driver_rating IS NULL OR status = 'completed')
);

-- Accounts belong to either a user or the company side, same
-- discriminator pattern as vehicle.
CREATE TABLE bank_account (
    account_no   VARCHAR(20) PRIMARY KEY,
    acc_type     VARCHAR(10) NOT NULL CHECK (acc_type IN ('savings', 'current')),
    holder_name  VARCHAR(60) NOT NULL,
    bank_name    VARCHAR(60) NOT NULL,
    branch_name  VARCHAR(60),
    owner_type   VARCHAR(10) NOT NULL CHECK (owner_type IN ('user', 'company')),
    user_id      INTEGER REFERENCES app_user (user_id),
    company_id   INTEGER REFERENCES company (company_id),
    CHECK (
        (owner_type = 'user'    AND user_id IS NOT NULL    AND company_id IS NULL) OR
        (owner_type = 'company' AND company_id IS NOT NULL AND user_id IS NULL)
    )
);

CREATE TABLE payment (
    payment_id  INTEGER PRIMARY KEY,
    trip_id     INTEGER NOT NULL REFERENCES trip (trip_id),
    amount      NUMBER(10,2) NOT NULL CHECK (amount > 0),
    method      VARCHAR(10) NOT NULL CHECK (method IN ('cash', 'card', 'wallet')),
    paid_at     TIMESTAMP NOT NULL,
    account_no  VARCHAR(20) REFERENCES bank_account (account_no)
);

CREATE TABLE offer (
    offer_id      INTEGER PRIMARY KEY,
    name          VARCHAR(30) NOT NULL,
    discount_pct  NUMBER(5,2) NOT NULL CHECK (discount_pct BETWEEN 0 AND 100)
);

CREATE TABLE rider_offer (
    rider_id    INTEGER NOT NULL REFERENCES rider (rider_id),
    offer_id    INTEGER NOT NULL REFERENCES offer (offer_id),
    granted_at  TIMESTAMP NOT NULL,
    PRIMARY KEY (rider_id, offer_id)
);

-- Batched settlement to companies and sharers. One row per payout cycle
-- per payee. Replaces the old corporate_payment and
-- corporate_payment_sharer twins.
CREATE TABLE payout (
    payout_id     INTEGER PRIMARY KEY,
    payee_type    VARCHAR(10) NOT NULL CHECK (payee_type IN ('company', 'sharer')),
    company_id    INTEGER REFERENCES company (company_id),
    sharer_id     INTEGER REFERENCES ride_sharer (sharer_id),
    period_start  DATE NOT NULL,
    period_end    DATE NOT NULL,
    amount        NUMBER(10,2) NOT NULL CHECK (amount > 0),
    paid_at       TIMESTAMP,
    account_no    VARCHAR(20) REFERENCES bank_account (account_no),
    CHECK (period_end > period_start),
    CHECK (
        (payee_type = 'company' AND company_id IS NOT NULL AND sharer_id IS NULL) OR
        (payee_type = 'sharer'  AND sharer_id  IS NOT NULL AND company_id IS NULL)
    )
);
