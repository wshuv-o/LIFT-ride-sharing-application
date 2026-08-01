# Requirements

Original scenario for the LIFT database, converted from Scenario.docx so it can be versioned and diffed.

## Scenario

The owner of a ride-sharing company named LIFT wants a database for his company.

- LIFT operates a mixed fleet. It owns vehicles itself, hires vehicles from sub-companies, and takes vehicles from individual ride sharers.
- Sub-companies pay LIFT a percentage of the income their vehicles earn, since those vehicles operate under the LIFT brand.
- Each vehicle has a model, registration number, type, base rate, brand, and a unique id.
- All vehicles are parked in LIFT's own garage. A garage has an id, name, and address.
- There are two kinds of platform users: drivers and riders. Every driver and rider is a user with a name, unique id, date of birth, address, email, phone number, and gender.
- Each driver drives exactly one vehicle. LIFT's own vehicles get LIFT drivers, sub-company vehicles come with the company's driver, and a ride sharer drives their own vehicle.
- A rider books a trip by picking a pickup point and a destination. A driver near the rider's location is assigned.
- A trip stores start and end time, start and end location, trip price, rider rating, driver rating, and a unique trip id.
- At the end of a trip the rider pays the fare. Each payment stores an amount, payment time, and a unique payment id.
- Riders can hold offers (discounts) and have a rider type (bronze, silver, gold).
- After a settlement period (week or month) LIFT pays the sub-companies and ride sharers their share of the fares their vehicles earned. Each payout stores an account number, amount, payment time, and a unique payout id.
- Locations carry a zip code and coordinates.
- Users and the companies hold bank accounts. Each account has a bank name, branch name, holder name, account type, and a unique account number.

## Functional expectations

1. Book a trip, assign the nearest free driver, run it to completion, and take payment, all with consistent data.
2. Compute what LIFT owes each vehicle owner per settlement cycle.
3. Answer operational questions: driver utilization, demand by hour and zone, rider value, driver quality.
