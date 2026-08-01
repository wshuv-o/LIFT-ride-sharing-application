-- Deterministic seed data. Fares follow the pricing rule
-- fare = base_rate + rate_per_km * distance_km, so the numbers here can
-- be recomputed by the tests.

INSERT INTO app_user VALUES (1,  'Fardin',   'Tasfin', 'fardin.tasfin@gmail.com',   '01773299857', '1995-03-08', 'male',   'Mohammadpur, Dhaka');
INSERT INTO app_user VALUES (2,  'Nusrat',   'Jahan',  'nusrat.jahan@gmail.com',    '01895642625', '1997-12-10', 'female', 'Banani, Dhaka');
INSERT INTO app_user VALUES (3,  'Maruf',    'Rafi',   'maruf.rafi@gmail.com',      '01764054545', '2000-01-07', 'male',   'Dhanmondi, Dhaka');
INSERT INTO app_user VALUES (4,  'Arif',     'Ashik',  'arif.ashik@gmail.com',      '01789394070', '1995-11-05', 'male',   'Uttara, Dhaka');
INSERT INTO app_user VALUES (5,  'Rifat',    'Sayeed', 'rifat.sayeed@gmail.com',    '01586713739', '1999-10-10', 'male',   'Mirpur, Dhaka');
INSERT INTO app_user VALUES (6,  'Mohammad', 'Rubel',  'mohammad.rubel@gmail.com',  '01945975361', '1997-09-03', 'male',   'Motijheel, Dhaka');
INSERT INTO app_user VALUES (7,  'Swapnil',  'Nazir',  'swapnil.nazir@gmail.com',   '01770245982', '1993-02-11', 'male',   'Gulshan, Dhaka');
INSERT INTO app_user VALUES (8,  'Atif',     'Siam',   'atif.siam@gmail.com',       '01561732077', '1994-12-01', 'male',   'Bashundhara, Dhaka');
INSERT INTO app_user VALUES (9,  'Salman',   'Hridoy', 'salman.hridoy@gmail.com',   '01561732078', '1999-04-05', 'male',   'Mirpur, Dhaka');
INSERT INTO app_user VALUES (10, 'Tanvir',   'Hasan',  'tanvir.hasan@gmail.com',    '01711223344', '1990-06-15', 'male',   'Dhanmondi, Dhaka');
INSERT INTO app_user VALUES (11, 'Sadia',    'Islam',  'sadia.islam@gmail.com',     '01822334455', '1992-08-22', 'female', 'Uttara, Dhaka');
INSERT INTO app_user VALUES (12, 'Rakib',    'Khan',   'rakib.khan@gmail.com',      '01933445566', '2001-05-30', 'male',   'Banani, Dhaka');

INSERT INTO company VALUES (1, 'Eagle One Delivery', 'Katasur, Mohammadpur, Dhaka 1207',      20.00);
INSERT INTO company VALUES (2, 'N-Motion Auto',      'Bangla Motor, Dhaka 1000',              15.00);
INSERT INTO company VALUES (3, 'Total Quality',      'Block A, Mirpur 11, Dhaka 1218',        25.00);

-- Users 10 and 11 plug their own cars into the fleet and drive them.
INSERT INTO ride_sharer VALUES (1, 10, 20.00);
INSERT INTO ride_sharer VALUES (2, 11, 20.00);

INSERT INTO garage VALUES (1, 'LIFT Central Garage', 'Tejgaon Industrial Area, Dhaka 1208');

--                          id  reg            model            brand     type          base   /km    owner      comp  shr  garage
INSERT INTO vehicle VALUES (1, 'DHK-GA-1123', 'Corolla Axio',   'Toyota', 'sedan',      80.00, 32.00, 'lift',    NULL, NULL, 1);
INSERT INTO vehicle VALUES (2, 'DHK-KHA-2210','Alto 800',       'Suzuki', 'micro',      50.00, 20.00, 'lift',    NULL, NULL, 1);
INSERT INTO vehicle VALUES (3, 'DHK-LA-3320', 'Pulsar 150',     'Bajaj',  'bike',       40.00, 15.00, 'lift',    NULL, NULL, 1);
INSERT INTO vehicle VALUES (4, 'DHK-GA-4415', 'Hyundai Aura',   'Hyundai','sedan',      80.00, 30.00, 'company', 1,    NULL, 1);
INSERT INTO vehicle VALUES (5, 'DHK-CHA-5511','Nissan Quest',   'Nissan', 'minivan',   120.00, 38.00, 'company', 2,    NULL, 1);
INSERT INTO vehicle VALUES (6, 'DHK-KHA-6612','Swift',          'Suzuki', 'subcompact', 60.00, 22.00, 'company', 3,    NULL, 1);
INSERT INTO vehicle VALUES (7, 'DHK-GA-7714', 'City',           'Honda',  'sedan',      85.00, 33.00, 'sharer',  NULL, 1,    1);
INSERT INTO vehicle VALUES (8, 'DHK-GHA-8817','X-Trail',        'Nissan', 'suv',       150.00, 45.00, 'sharer',  NULL, 2,    1);

INSERT INTO location VALUES (1, '1212', 'Gulshan',     23.792500, 90.407800);
INSERT INTO location VALUES (2, '1213', 'Banani',      23.793700, 90.406600);
INSERT INTO location VALUES (3, '1209', 'Dhanmondi',   23.746100, 90.374200);
INSERT INTO location VALUES (4, '1216', 'Mirpur',      23.804200, 90.366700);
INSERT INTO location VALUES (5, '1230', 'Uttara',      23.875900, 90.379500);
INSERT INTO location VALUES (6, '1000', 'Motijheel',   23.733000, 90.417200);
INSERT INTO location VALUES (7, '1207', 'Mohammadpur', 23.757400, 90.365400);
INSERT INTO location VALUES (8, '1229', 'Bashundhara', 23.819500, 90.429200);

--                         id  user  license          vehicle  at
INSERT INTO driver VALUES (1,  6,   'DHA-D-114523',   1,       1);
INSERT INTO driver VALUES (2,  7,   'DHA-D-227810',   2,       4);
INSERT INTO driver VALUES (3,  8,   'DHA-D-339045',   4,       2);
INSERT INTO driver VALUES (4,  9,   'DHA-D-441267',   5,       6);
INSERT INTO driver VALUES (5,  10,  'DHA-D-556678',   7,       3);
INSERT INTO driver VALUES (6,  11,  'DHA-D-668821',   8,       5);

INSERT INTO rider VALUES (1, 1,  'gold');
INSERT INTO rider VALUES (2, 2,  'silver');
INSERT INTO rider VALUES (3, 3,  'silver');
INSERT INTO rider VALUES (4, 4,  'bronze');
INSERT INTO rider VALUES (5, 5,  'gold');
INSERT INTO rider VALUES (6, 12, 'bronze');

-- June trips (settled in the July 2 payout run)
INSERT INTO trip VALUES (1,  1, 1, 1, 1, 6, '2023-06-05 08:15:00', '2023-06-05 08:20:00', '2023-06-05 08:55:00',  7.50, 320.00, 'completed', 5, 4);
INSERT INTO trip VALUES (2,  2, 3, 4, 3, 1, '2023-06-05 09:02:00', '2023-06-05 09:06:00', '2023-06-05 09:40:00',  8.20, 326.00, 'completed', 4, 5);
INSERT INTO trip VALUES (3,  3, 4, 5, 5, 6, '2023-06-08 18:30:00', '2023-06-08 18:35:00', '2023-06-08 19:25:00', 16.40, 743.20, 'completed', 5, 5);
INSERT INTO trip VALUES (4,  1, 5, 7, 2, 3, '2023-06-12 18:45:00', '2023-06-12 18:50:00', '2023-06-12 19:20:00',  6.80, 309.40, 'completed', 4, 4);
INSERT INTO trip VALUES (5,  4, 6, 8, 8, 5, '2023-06-15 22:10:00', '2023-06-15 22:14:00', '2023-06-15 22:40:00',  9.30, 568.50, 'completed', 5, 3);
INSERT INTO trip VALUES (6,  2, 2, 2, 4, 7, '2023-06-20 08:05:00', '2023-06-20 08:09:00', '2023-06-20 08:35:00',  5.60, 162.00, 'completed', 3, 4);

-- July trips (not settled yet, they show up in v_payout_due)
INSERT INTO trip VALUES (7,  5, 1, 1, 6, 1, '2023-07-03 08:30:00', '2023-07-03 08:34:00', '2023-07-03 09:10:00',  7.50, 320.00, 'completed', 5, 5);
INSERT INTO trip VALUES (8,  1, 3, 4, 1, 5, '2023-07-04 19:00:00', '2023-07-04 19:05:00', '2023-07-04 19:50:00', 12.70, 461.00, 'completed', 4, 4);
INSERT INTO trip VALUES (9,  3, 5, 7, 3, 4, '2023-07-08 08:50:00', '2023-07-08 08:55:00', '2023-07-08 09:30:00',  9.90, 411.70, 'completed', 5, 4);
INSERT INTO trip VALUES (10, 2, 4, 5, 2, 8, '2023-07-11 18:20:00', '2023-07-11 18:26:00', '2023-07-11 18:55:00',  6.40, 363.20, 'completed', 4, 5);
INSERT INTO trip VALUES (11, 4, 2, 2, 7, 3, '2023-07-15 12:40:00', '2023-07-15 12:44:00', '2023-07-15 13:05:00',  3.90, 128.00, 'completed', 5, 5);
INSERT INTO trip VALUES (12, 5, 6, 8, 5, 1, '2023-07-21 20:15:00', '2023-07-21 20:20:00', '2023-07-21 21:00:00', 14.80, 816.00, 'completed', 4, 5);

-- Cancellations and live traffic
INSERT INTO trip VALUES (13, 3, NULL, NULL, 1, NULL, '2023-07-22 08:40:00', NULL, NULL, NULL, NULL, 'cancelled', NULL, NULL);
INSERT INTO trip VALUES (14, 1, 4,    5,    2, 8,    '2023-07-25 18:05:00', NULL, NULL, NULL, NULL, 'cancelled', NULL, NULL);
INSERT INTO trip VALUES (15, 2, 1,    1,    1, 6,    '2023-07-28 09:00:00', '2023-07-28 09:05:00', NULL, NULL, NULL, 'in_progress', NULL, NULL);
INSERT INTO trip VALUES (16, 5, 6,    8,    5, 2,    '2023-07-28 09:02:00', NULL, NULL, NULL, NULL, 'assigned', NULL, NULL);
INSERT INTO trip VALUES (17, 4, NULL, NULL, 6, 3,    '2023-07-28 09:04:00', NULL, NULL, NULL, NULL, 'requested', NULL, NULL);

INSERT INTO bank_account VALUES ('ACC-U01-4432', 'savings', 'Fardin Tasfin',      'BRAC Bank',   'Mohammadpur', 'user',    1,    NULL);
INSERT INTO bank_account VALUES ('ACC-U02-8810', 'savings', 'Nusrat Jahan',       'City Bank',   'Banani',      'user',    2,    NULL);
INSERT INTO bank_account VALUES ('ACC-U10-1276', 'current', 'Tanvir Hasan',       'EBL',         'Dhanmondi',   'user',    10,   NULL);
INSERT INTO bank_account VALUES ('ACC-U11-3391', 'savings', 'Sadia Islam',        'BRAC Bank',   'Uttara',      'user',    11,   NULL);
INSERT INTO bank_account VALUES ('ACC-C01-0007', 'current', 'Eagle One Delivery', 'Sonali Bank', 'Motijheel',   'company', NULL, 1);
INSERT INTO bank_account VALUES ('ACC-C02-0019', 'current', 'N-Motion Auto',      'Janata Bank', 'Kawran Bazar','company', NULL, 2);
INSERT INTO bank_account VALUES ('ACC-C03-0023', 'current', 'Total Quality',      'Rupali Bank', 'Mirpur',      'company', NULL, 3);

-- One payment per completed trip, amount equals the fare (trigger enforced)
INSERT INTO payment VALUES (1,  1,  320.00, 'cash',   '2023-06-05 08:56:00', NULL);
INSERT INTO payment VALUES (2,  2,  326.00, 'card',   '2023-06-05 09:41:00', 'ACC-U02-8810');
INSERT INTO payment VALUES (3,  3,  743.20, 'wallet', '2023-06-08 19:26:00', NULL);
INSERT INTO payment VALUES (4,  4,  309.40, 'card',   '2023-06-12 19:22:00', 'ACC-U01-4432');
INSERT INTO payment VALUES (5,  5,  568.50, 'cash',   '2023-06-15 22:41:00', NULL);
INSERT INTO payment VALUES (6,  6,  162.00, 'wallet', '2023-06-20 08:36:00', NULL);
INSERT INTO payment VALUES (7,  7,  320.00, 'cash',   '2023-07-03 09:12:00', NULL);
INSERT INTO payment VALUES (8,  8,  461.00, 'card',   '2023-07-04 19:52:00', 'ACC-U01-4432');
INSERT INTO payment VALUES (9,  9,  411.70, 'wallet', '2023-07-08 09:31:00', NULL);
INSERT INTO payment VALUES (10, 10, 363.20, 'cash',   '2023-07-11 18:57:00', NULL);
INSERT INTO payment VALUES (11, 11, 128.00, 'cash',   '2023-07-15 13:06:00', NULL);
INSERT INTO payment VALUES (12, 12, 816.00, 'card',   '2023-07-21 21:03:00', 'ACC-U02-8810');

INSERT INTO offer VALUES (1, 'WELCOME10', 10.00);
INSERT INTO offer VALUES (2, 'GOLD15',    15.00);
INSERT INTO offer VALUES (3, 'EID20',     20.00);

INSERT INTO rider_offer VALUES (1, 2, '2023-06-01 00:00:00');
INSERT INTO rider_offer VALUES (5, 2, '2023-06-01 00:00:00');
INSERT INTO rider_offer VALUES (6, 1, '2023-07-10 00:00:00');
INSERT INTO rider_offer VALUES (2, 3, '2023-06-20 00:00:00');

-- June settlement, paid July 2. Net = fare minus LIFT commission.
--   Eagle One:  326.00 * 0.80 = 260.80
--   N-Motion:   743.20 * 0.85 = 631.72
--   Sharer 1:   309.40 * 0.80 = 247.52
--   Sharer 2:   568.50 * 0.80 = 454.80
INSERT INTO payout VALUES (1, 'company', 1,    NULL, '2023-06-01', '2023-07-01', 260.80, '2023-07-02 10:00:00', 'ACC-C01-0007');
INSERT INTO payout VALUES (2, 'company', 2,    NULL, '2023-06-01', '2023-07-01', 631.72, '2023-07-02 10:00:00', 'ACC-C02-0019');
INSERT INTO payout VALUES (3, 'sharer',  NULL, 1,    '2023-06-01', '2023-07-01', 247.52, '2023-07-02 10:05:00', 'ACC-U10-1276');
INSERT INTO payout VALUES (4, 'sharer',  NULL, 2,    '2023-06-01', '2023-07-01', 454.80, '2023-07-02 10:05:00', 'ACC-U11-3391');
