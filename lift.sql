CREATE TABLE users( user_id NUMBER(10), 
    first_name VARCHAR(15), 
    last_name VARCHAR(15), 
    dob DATE, 
    address VARCHAR(100),  
    phone VARCHAR(11), 
    gender VARCHAR(10), 
    CONSTRAINT user_id_pk PRIMARY KEY(user_id) 
    )

CREATE TABLE Users_Account(Account_No VARCHAR(20) constraint Account_No_pk primary key
    acc_type VARCHAR(15)
    accHldr_name VARCHAR(25)
    Bank_Name VARCHAR(35)
    Branch_Name VARCHAR(30)
    user_id NUMBER(10) CONSTRAINT users_account_id_fk REFERENCES users(user_id)
    );


CREATE TABLE ride_sharer(sharer_id NUMBER(10) constraint RIDE_SHARER_pk primary key
    sharer_age NUMBER(2)
    user_id NUMBER(10) CONSTRAINT sharer_user_id_fk REFERENCES users(user_id)
    );


CREATE TABLE rider(rider_id NUMBER(10) constraint rider_pk primary key,
rider_type VARCHAR(20),
user_id NUMBER(10) CONSTRAINT rider_id_fk REFERENCES users(user_id)
      );


CREATE TABLE company(comp_id NUMBER(5) constraint COMP_pk primary key
comp_name VARCHAR(30)
comp_address VARCHAR(100)
);


CREATE TABLE Comp_Account(Account_No varchar(20) constraint Account_No_pk primary key,
    acc_type VARCHAR(15),  
    accHldr_name VARCHAR(25),  
    Bank_Name VARCHAR(35),  
    Branch_Name VARCHAR(30),  
    Comp_id VARCHAR(5) constraint comp_account_id_fk references(comp_id));

CREATE TABLE company_vehicle(vehicle_id NUMBER(10) constraint comp_vhcl_pk primary key
    vehicle_model VARCHAR(15),
    vehicle_reg VARCHAR(15),
    vehicle_type VARCHAR(15),
    base_rate NUMBER(5),
    vehicle_brand VARCHAR(15),
    comp_id NUMBER(5) CONSTRAINT VEHICLE_comp_id_fk REFERENCES company(comp_id)
    );


CREATE TABLE company_driver(driver_id NUMBER(10) constraint COMP_driver_pk primary key
    comp_id NUMBER(5) CONSTRAINT driver_comp_id_fk REFERENCES company(comp_id)
    );


CREATE TABLE corporate_payment(CorporatePayment_id NUMBER(10) constraint CORPORATE_pk primary key,
    Corporatepayment_time VARCHAR(30) ,
    Corporate_Acc_no VARCHAR(15) ,
    CorporateAmount NUMBER(10) ,
    comp_id NUMBER(5) CONSTRAINT CORPORATE_id_fk REFERENCES company(comp_id)
    );


CREATE TABLE garage( garage_id NUMBER(5) constraint garage_pk primary key,
    garage_name VARCHAR(20),
    Address VARCHAR(50),
    );


CREATE TABLE garage_vehicle(vehicle_id NUMBER(10),
    vehicle_model VARCHAR(15),
    vehicle_reg VARCHAR(15),
    vehicle_type VARCHAR(15),
    base_rate NUMBER(5),
    vehicle_brand VARCHAR(15),
    garage_id NUMBER(5) CONSTRAINT VEHICLE_garage_id_fk REFERENCES garage(garage_id)
    );


CREATE TABLE garage_driver(driver_id NUMBER(10) constraint gd_pk primary key
    garage_id NUMBER(5) CONSTRAINT driver_garage_id_fk REFERENCES garage(garage_id)
    );


CREATE TABLE vehicle_driver(driver_id NUMBER(10) constraint vd_pk primary key
    vehicle_id NUMBER(10) CONSTRAINT vehicle_driver_id_fk REFERENCES company_vehicle(vehicle_id)
    );



create table CORPORATE_PAYMENT_sharer(Corporate_Payment_id VARCHAR(10),
    Corporate_payment_time VARCHAR(20),
    Corporate_Acc_no VARCHAR(17),
    Corporate_Amount NUMBER(15),
    Sharer_id NUMBER(10) CONSTRAINT CP_SHARER_fk REFERENCES ride_sharer(sharer_id),
    CONSTRAINT CORPORATE_PAYMENT_ID_KEY PRIMARY KEY(Corporate_Payment_id)
    );


create table LOCATION(loc_id VARCHAR(10) NOT NULL,
    zip_code VARCHAR(5),
    mapgrid_id VARCHAR(10) CONSTRAINT loc_fk REFERENCES MAP(mapgrid_id),
    CONSTRAINT loc_id_KEY PRIMARY KEY(loc_id) 
   );


create table MAP(mapgrid_id VARCHAR(10) NOT NULL ,
    longitude NUMBER(3,6),
    latitude NUMBER(3,6) ,
    CONSTRAINT mapgrid_id_KEY PRIMARY KEY(mapgrid_id)  
   );

 

CREATE TABLE Payment( Payment_ID NUMBER(1,10) not null,
    Payment_Time VARCHAR(20),
    Amount VARCHAR(9),
    Rider_ID NUMBER(10) constraint rider_pay_fk REFERENCES RIDER(rider_id),
    Account_No VARCHAR(15),
    Acc_Type VARCHAR(5),
    constraint Payment_pk primary key (Payment_ID)
    );


CREATE TABLE Trip( Trip_ID NUMBER(10) not null,
    Trip_Price VARCHAR(9),
    Trip_Start_Time VARCHAR(15),
    Trip_End_Time VARCHAR(15),
    Start_Loc_ID VARCHAR(10),
    End_Loc_ID VARCHAR(10),
    vehicle_ID NUMBER(10) constraint trip_vehicle_fk REFERENCES                                                                 vehicle(vehicle_id),
    Driver_Rating VARCHAR(10),
    Rider_ID NUMBER(10) constraint trip_rider_fk REFERENCES rider(rider_id),
    Rider_Rating VARCHAR(10),
    constraint Trip_pk primary key (Trip_ID)
    );


CREATE TABLE Offers(Offers_ID NUMBER(4) not null,
    Offers_Name VARCHAR(10),
    Discount NUMBER(3),
    constraint Offers_pk primary key (Offers_ID)
    );

CREATE TABLE Rider_Offers(Rider_Offers_ID NUMBER(5) not null,
    Offers_ID NUMBER(4) constraint offr_id_fk REFERENCES offers(offers_id),
    Rider_ID NUMBER(10) constraint rdr_id_fk REFERENCES rider(rider_id),
    constraint Rider_Offers_pk primary key (Rider_Offers_ID)
    );


CREATE TABLE Driver(Driver_ID VARCHAR(7) not null,
    Sharer_ID NUMBER(8) constraint sharer_driver_fk REFERENCES ride_sharer(sharer_id),
    constraint Driver_pk primary key (Driver_ID)
    );

CREATE TABLE sharer_vehicle(vehicle_id NUMBER(10),
    vehicle_model VARCHAR(15),
    vehicle_reg VARCHAR(15),
    vehicle_type VARCHAR(15),
    base_rate NUMBER(5),
    vehicle_brand VARCHAR(15),
    sharer_id NUMBER(5) CONSTRAINT VEHICLE_sharer_id_fk REFERENCES ride_sharer(sharer_id)
    );


--Value Insertion
--Company

CREATE SEQUENCE comp_seq 
start with 60 
increment by 10 
minvalue 60 
maxvalue 200 
nocycle nocache;

INSERT INTO company values(comp_seq.nextval, 'Eagle One Delivery','katasur, sher-e-bangla road, mohammadpur, 1207');
INSERT INTO company values(comp_seq.nextval, 'First Call Auto','dhonanjoypur, ashulia, savar, 1340');
INSERT INTO company values(comp_seq.nextval, 'N-Motion Auto','home town, (10th floor), bangla motor, 1000');
INSERT INTO company values(comp_seq.nextval, 'Total Quality','road # 4, block - a, mirpur - 11, 1218');
INSERT INTO company values(comp_seq.nextval, 'Only Logistic','block - c, banasree, east rampura, 1219');
INSERT INTO company values(comp_seq.nextval, 'National Carrier Inc','Medona Tower (8th Floor), 28 Mohakhali C/A, P.O. Box: 1212');

--Company_vehicle

INSERT INTO COMPANY_VEHICLE('2334', 'auris','5/8/2009','Micro',500,'toyota',70);
INSERT INTO COMPANY_VEHICLE('3456','swift','7/2/2012','Subcompact',    240,'suzuki',80);
INSERT INTO COMPANY_VEHICLE('5672', 'ibiza','4/6/2010','Sedan',567,'seat',60);
INSERT INTO COMPANY_VEHICLE('5681', 'Hyundai Aura','3/9/2010','Sedan',643,'Hyundai',60);
INSERT INTO 
COMPANY_VEHICLE('6781', 'Nissan Quest','7/2/2003','Minivan',672,'Nissan',110);

INSERT INTO 
COMPANY_VEHICLE('6789', 'Toyota Prius','4/1/2011','Sedan',567,'ford',60);


--comp_driver_seq

CREATE SEQUENCE comp_driver_seq start with 100 increment by 2 minvalue 60
		 maxvalue 200 nocycle nocache;
INSERT INTO company_driver values(comp_driver_seq.nextval, 70);
INSERT INTO company_driver values(comp_driver_seq.nextval, 60);
INSERT INTO company_driver values(comp_driver_seq.nextval, 70);
INSERT INTO company_driver values(comp_driver_seq.nextval, 60);
INSERT INTO company_driver values(comp_driver_seq.nextval, 80);
INSERT INTO company_driver values(comp_driver_seq.nextval, 110);


--USERS
CREATE SEQUENCE user_seq start with 100000 increment by 2 minvalue 100000  maxvalue 99990000 nocycle nocache;
INSERT INTO USERS VALUES (USER_SEQ.NEXTVAL,'Fardin','Tasfin',TO_DATE('03/08/1995', 'mm/dd/yyyy'), 'fardin.tasfin@gmail.com','01773299857','Male');

INSERT INTO USERS VALUES (USER_SEQ.NEXTVAL,'md','Seaam',TO_DATE('10/12/1997', 'dd/mm/yyyy'),'md.seaam@gmail.com','01895642625','Male');

INSERT INTO USERS VALUES (USER_SEQ.NEXTVAL,'Maruf','Rafi',TO_DATE('07/01/2000', 'dd/mm/yyyy'),'maruf.rafi@gmail.com','01764054545','Male');

INSERT INTO USERS VALUES (USER_SEQ.NEXTVAL,'Arif','ASHIK',TO_DATE('05/11/1995', 'dd/mm/yyyy'),'arif.ashik@gmail.com','01789394070','Male');

INSERT INTO USERS VALUES (USER_SEQ.NEXTVAL,'Rifat','sayeed',TO_DATE('10/10/1999', 'dd/mm/yyyy'),'rifat.sayeed@gmail.com','01586713739','Male');

INSERT INTO USERS VALUES (USER_SEQ.NEXTVAL,'Mohammad',' Rubel',TO_DATE('03/09/1997','dd/mm/yyyy'),'mohammad.rubel@gmail.com',
'0194597536','Male');
INSERT INTO USERS VALUES (USER_SEQ.NEXTVAL,'swapnil','Nazir',TO_DATE('11/2/2017', 'dd/mm/yyyy'),'swapnil.nazir@gmail.com','01770245982','Male');

INSERT INTO USERS VALUES (USER_SEQ.NEXTVAL,'Atif','SIAM',TO_DATE('01/12/2003', 'dd/mm/yyyy'),'atif.siam@gmail.com','01561732077','Male');

INSERT INTO USERS VALUES (USER_SEQ.NEXTVAL,'Salman','hridoy',TO_DATE('5/4/1999', 'dd/mm/yyyy'),'salman.hridoy@gmail.com','01561732078','Male');

--RIDER
CREATE SEQUENCE RIDER_SEQ start with 100000 increment by 2 minvalue 100000  maxvalue 99990000 nocycle nocache;
INSERT INTO rider VALUES (rider_seq.NEXTVAL,'SILVER',10004);
INSERT INTO rider VALUES (rider_seq.NEXTVAL,'GOLD',10004);
INSERT INTO rider VALUES (rider_seq.NEXTVAL,'SILVER',10005);
INSERT INTO rider VALUES (rider_seq.NEXTVAL,'BRONZE',10003);
INSERT INTO rider VALUES (rider_seq.NEXTVAL,'SILVER',10004);

--CORPORATE_PAYMENT
INSERT INTO corporate_payment VALUES(4449,'2022-04-30 14:53:27', '0094676167923',1265000,60);
INSERT INTO corporate_payment VALUES(1192,'2022-05-30 14:33:27', '00459546105951',456619,70);
INSERT INTO corporate_payment VALUES(5620,'2022-06-13 11:02:12', '00378101817920',117901,90);
INSERT INTO corporate_payment VALUES(9232,'2022-11-15 15:44:17', '00607450408991',807877,100);
INSERT INTO corporate_payment VALUES(9464,'2021-09-18 17:06:11', '01202093996046',894571,70);
INSERT INTO corporate_payment VALUES(3483,'2022-01-21 17:38:22', '00543774605356',169427,60);
INSERT INTO corporate_payment VALUES(5254,'2022-02-05 11:30:40', '003382786769',238880,100);
INSERT INTO corporate_payment VALUES(7261,'2021-08-16 19:20:37', '00864416451720',668041,70);
INSERT INTO corporate_payment VALUES(1098,'2021-12-06 10:12:19', '0094676167923',960811,90);

--COMP_ACCOUNT
INSERT INTO COMP_ACCOUNT VALUES ('00950201003772432','Savings','shamim ahnaf','Agrani Bank Limited','Bahaddarhat',70);
INSERT INTO COMP_ACCOUNT VALUES ('00950201045712432','Savings','fardin tasfin','Bangladesh Development Bank','Barisal',60);

INSERT INTO COMP_ACCOUNT VALUES ('00960201201022432','Savings','md seaam','BASIC Bank Limited','Bogra',70);

INSERT INTO COMP_ACCOUNT VALUES ('00970201204362432','Savings','maruf rafi','Janata Bank Limited','Ashuganj',110);

INSERT INTO COMP_ACCOUNT VALUES ('00980201303182432','Savings','arif ashik','Rupali Bank Limited','Brahmanbaria',70);

INSERT INTO COMP_ACCOUNT VALUES ('00940207002562432','Savings','rifat sayeed','Sonali Bank Limited','Chandpur',60);

INSERT INTO COMP_ACCOUNT VALUES ('01000201501302432','Savings','mohammad rubel','Agrani Bank Limited','ChapaiNawabganj',60); 

INSERT INTO COMP_ACCOUNT VALUES ('01010201504932432','Savings','swapnil nazir','Bangladesh Development Bank','Agrabad',80);

INSERT INTO COMP_ACCOUNT VALUES ('00960201507982432','Savings','atif siam','BASIC Bank Limited','Anderkilla',80);


--RIDE_SHARER

CREATE SEQUENCE RIDE_SHARER_SEQ start with 5000 increment by 2 minvalue 10000 maxvalue 99990000 nocycle nocache;
INSERT INTO RIDE_SHARER VALUES (RIDE_SHARER_SEQ.NEXTVAL,20,100042);
INSERT INTO RIDE_SHARER VALUES (RIDE_SHARER_SEQ.NEXTVAL,28,100044);
INSERT INTO RIDE_SHARER VALUES (RIDE_SHARER_SEQ.NEXTVAL,35,100048);
INSERT INTO RIDE_SHARER VALUES (RIDE_SHARER_SEQ.NEXTVAL,45,100050);
INSERT INTO RIDE_SHARER VALUES (RIDE_SHARER_SEQ.NEXTVAL,99,100040);


--corporate_payment_SHARER

INSERT INTO corporate_payment_SHARER VALUES(4440,'2022-04-31 10:53:27', '0094676167923',26500,10000);
INSERT INTO corporate_payment_SHARER VALUES(1190,'2022-05-31 10:33:27', '00459546105951',5660,10002);
INSERT INTO corporate_payment_SHARER VALUES(5620,'2022-06-11 10:02:12', '00378101817920',1790,10004);
INSERT INTO corporate_payment_SHARER VALUES(9230,'2022-11-11 10:44:17', '00607450408991',1780,10006);
INSERT INTO corporate_payment_SHARER VALUES(9460,'2021-09-11 10:06:11', '01202093996046',9450,10008);
INSERT INTO corporate_payment_SHARER VALUES(3480,'2022-01-21 10:38:22', '00543774605356',6940,10006);

--DRIVER
CREATE SEQUENCE DRIVER_SEQ start with 10000 increment by 2 minvalue 10000  maxvalue 1990000 nocycle nocache;
INSERT INTO driver VALUES(DRIVER_SEQ.NEXTVAL,10000);
INSERT INTO driver VALUES(DRIVER_SEQ.NEXTVAL,10002);
INSERT INTO driver VALUES(DRIVER_SEQ.NEXTVAL,10004);
INSERT INTO driver VALUES(DRIVER_SEQ.NEXTVAL,10006);
INSERT INTO driver VALUES(DRIVER_SEQ.NEXTVAL,10008);

--GARAGE_DRIVER
CREATE SEQUENCE G_DRIVER_SEQ start with 10000 increment by 2 minvalue 10000  maxvalue 1990000 nocycle nocache;
INSERT INTO GARAGE_DRIVER VALUES(G_DRIVER_SEQ.NEXTVAL,5024);
INSERT INTO GARAGE_DRIVER VALUES(G_DRIVER_SEQ.NEXTVAL,5018);
INSERT INTO GARAGE_DRIVER VALUES(G_DRIVER_SEQ.NEXTVAL,5020);
INSERT INTO GARAGE_DRIVER VALUES(G_DRIVER_SEQ.NEXTVAL,5030);
INSERT INTO GARAGE_DRIVER VALUES(G_DRIVER_SEQ.NEXTVAL,5034);
