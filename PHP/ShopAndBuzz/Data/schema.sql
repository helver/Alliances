drop table BUZZ_USER CASCADE;

create table BUZZ_USER (
  id		serial,
  email		varchar(70) NOT NULL UNIQUE,
  username	varchar(70) NOT NULL UNIQUE,
  password	text NOT NULL,
  admin_code    int NOT NULL DEFAULT 0,
  last_auth     timestamp,
  email_confirmed boolean NOT NULL DEFAULT 'f',
  email_token text,
  primary key (id)
);

drop index username_key;
drop index usernameEmail_key;
drop index userpassword_key;

create index username_key on BUZZ_USER (username);
create index usernameEmail_key on BUZZ_USER (email);
create index userpassword_key on buzz_user (password);

drop table UNCONFIRMED_USER;

create table UNCONFIRMED_USER (
  email text,
  username text,
  password text,
  token text,
  paypal_user text,
  ebay_username text,
  add_date TIMESTAMP,
  realname text,
  primary key (token)
);

drop index unconfirmed_user_index;

create index unconfirmed_user_index on UNCONFIRMED_USER (token);

drop table BUZZ_USER_PROFILE;
create table BUZZ_USER_PROFILE (
  buzz_user_id int,
  description text,
  paypal_email text UNIQUE,
  email_pref int NOT NULL DEFAULT 1,
  ebay_good_standing int2,
  realname text,
  ebay_power_seller varchar(20),
  primary key (buzz_user_id)
);

drop table USER_PROFILE_MESGS;
create table USER_PROFILE_MESGS (
  id SERIAL PRIMARY KEY,
  buzz_user_id int,
  message text,
  date_added timestamp
);

drop index profile_mesg_index;
create index profile_mesg_index on USER_PROFILE_MESGS (buzz_user_id);

drop table ADMIN_LEVEL;
create table ADMIN_LEVEL (
  code		int,
  value		text,
  primary key (code)
);

insert into ADMIN_LEVEL (code, value) VALUES (0, 'user');
insert into ADMIN_LEVEL (code, value) VALUES (1, 'admin');
insert into ADMIN_LEVEL (code, value) VALUES (2, 'superuser');

drop table EMAIL_FREQ;
create table EMAIL_FREQ (
  preference	int,
  value		text,
  primary key(preference)
);

insert into EMAIL_FREQ (preference, value) VALUES (0, 'never');
insert into EMAIL_FREQ (preference, value) VALUES (1, 'immediate');
insert into EMAIL_FREQ (preference, value) VALUES (2, 'daily');
insert into EMAIL_FREQ (preference, value) VALUES (3, 'weekly');
insert into EMAIL_FREQ (preference, value) VALUES (4, 'monthly');

drop table BLOCKED_EMAILS;
create table BLOCKED_EMAILS (
  to_id		int,
  from_id	int
);

drop index blocked_email_from_index;
drop index blocked_email_to_index;
create index blocked_email_from_index on BLOCKED_EMAILS (from_id);
create index blocked_email_to_index on BLOCKED_EMAILS (to_id);

drop table SUSPENDED_USER;
create table SUSPENDED_USER (
  id		int NOT NULL UNIQUE,
  email		text NOT NULL UNIQUE,
  username      text NOT NULL UNIQUE,
  password      text,
  admin_code    int,
  email_pref    int,
  primary key (id)
);

drop table SELLER_INFO;
create table SELLER_INFO (
  buzz_user_id	int,
  category_id   int,
  feedback	int,
  positive_pct	decimal (5,2),
  powerseller	boolean NOT NULL DEFAULT ('false'),
  primary key (buzz_user_id)
);

drop index seller_category_index;
create index seller_category_index on SELLER_INFO (category_id);

-- account for possibility that seller is in multiple categories

drop table SELLER_CATEGORY CASCADE;
create table SELLER_CATEGORY (
  id serial,
  name text,
  description text,
  primary key (id)
);

drop index seller_cat_list_index;
create index seller_cat_list_index on SELLER_CATEGORY (name);

drop table HIVE;
create table HIVE (
  buzz_user_id int,
  member_id int,
  date_added timestamp
);

drop index hive_user_index;
create index hive_user_index on HIVE (buzz_user_id);
drop index hive_user_member_index;
create index hive_user_member_index on hive (buzz_user_id, member_id);

drop table HONEYCOMB;
create table HONEYCOMB (
  buzz_user_id	int,
  member_id	int,
  date_added	timestamp,
  recommendable	boolean
);

drop index honeycomb_user_index;
create index honeycomb_user_index on HONEYCOMB (buzz_user_id);

drop table REFERRAL CASCADE;
create table REFERRAL (
  id		serial,
  buzz_user_id	int,
  refer_user_id	int,
  seller_id	int,
  expiration	timestamp,
  date_added	timestamp,
  comm_schedule int,
  rebate_id	int,
  PRIMARY KEY (id)
);

drop index REFERRAL_BUYER_INDEX;
drop index REFERRAL_SELLER_INDEX;
create index REFERRAL_BUYER_INDEX on REFERRAL (buzz_user_id);
create index REFERRAL_SELLER_INDEX on REFERRAL (seller_id);

drop table PAYPAL;
create table PAYPAL (
  id 		serial,
  buzz_user_id	int,
-- need paypal info here
  invoice_sent	int,
  paid_invoice	int,
  amount	decimal(10,2),
  sold_to_id	int,
  full_name_to	text,
  email_addr_to	text,
  PRIMARY KEY (id)
);


drop table PAYPAL_TRANS;
create table PAYPAL_TRANS (
  id 		serial,
  buzz_user_id	int,
  commission_seller_id	int,
  sold_to_id	int,
  email_add_to	text,
  full_name_to	text,
  commisssion_paid	int,
  PRIMARY KEY (ID)
);


drop table RECOMMENDATION;
create table RECOMMENDATION (
  reco_id	serial,
  buzz_user_id	int,
  seller_id	int,
  num_purchases	int,
  speed_rating	int,
  expect_rating	int,
  value_rating	int,
  comm_rating	int,
  exp_rating	int,
  recommend	text,
  PRIMARY KEY (reco_id)
);

drop index SELLER_RECOMMEND_INDEX;
drop index BUYER_RECOMMDEND_INDEX;
create index SELLER_RECOMMEND_INDEX on RECOMMENDATION (seller_id);
create index BUYER_RECOMMDEND_INDEX on RECOMMENDATION (buzz_user_id);

drop table PURCHASES;
create table PURCHASES (
  id		serial,
  buyer_id	int,
  seller_id	int,
  referral_id	int REFERENCES referral(id) ON DELETE SET NULL,
  trans_date	timestamp,
  amount	decimal (10,2),
  paid_date	TIMESTAMP default NULL,
  cleard_upi		boolean NOT NULL DEFAULT 'false',
  processed	 boolean NOT NULL DEFAULT 'false',
  PRIMARY KEY (id)
);


drop index unprocessed_trans_idx;
create index unprocessed_trans_idx on purchases (paid_date, processed);

drop table PAID_COMMS;
create table PAID_COMMS (
   comm_id       INT,
  seller_id	int,
  payee_id	int,
  referral_id	int, -- foreign key
  purchase_id	int, -- foreign key
  paid_date	timestamp,
  amount	decimal (10,2),
  PRIMARY KEY (comm_id)
);

drop index PAYEE_COMMS_INDEX;
create index PAYEE_COMMS_INDEX on PAID_COMMS (payee_id);

drop table COMMISSION_SCHEDULE;
--create table COMMISSION_SCHEDULE (
--  seller_id	int,
 -- referal_id	int,
--  refer_cut_pct	decimal (5,2),
--  refer_cut_amt	decimal (10,2),
--  buyer_cut_pct	decimal (5,2),
--  buyer_cut_amt decimal (10,2),
--  buyer_cut_thr decimal (10,2),
--  add_date	timestamp,
--  duration_days int,
--  remaining_days int,
--  original_purch_limit	int,
--  remaining_purchases	int,
   
-- need to account for:
-- X   Flat fee per sale
--       refer_cut_amt (1st level, referer)
--       buyer_cut_amt (2nd level, buyer)
-- X   Percentage per sale
--       refer_cut_pct (1st level, referer)
--       buyer_cut_pct (2nd level, buyer)
-- X   % off purchase
--       buyer_cut_pct (2nd level, buyer)
-- X   flat amount off purchase exceeding threshhold.
--       buyer_cut_amt + buyer_cut_thr
-- X   Duration
--       add_date + duration_days
-- X   Schedule terminates after XX purchases
--       original_purchase_limit + remaining_purchases
-- A   Commission for purchases from previous Buyers?
--       This is handled in the engine, granting the
--       seller the ability to create a commission schedule
--       on a per-referal basis.
-- X   One time credit
--       Set the original_purch_limit to 1.
--);

drop table commission_schedule;
create table commission_schedule (
  id            BIGSERIAL,
  buzz_user_id  INTEGER,
  comm_level    INTEGER,
  active        BOOLEAN,
  amouNt        Decimal (10,2),
  max_limit         INTEGER,
  remain        INTEGER,
  min_pay_threshold DECIMAL(10,2) DEFAULT 0.0,
  max_amount    DECIMAL (10,2) DEFAULT 0.0,
  pay_type      TEXT,
  limit_type    TEXT,
  add_date      TIMESTAMP,
  myLabel	TEXT,
  PRIMARY KEY (id)
);

create index active_commission
       on commission_schedule (active, comm_level, buzz_user_id);
create index seller_commission
       on commission_schedule (buzz_user_id);


drop table FEE_SCHEDULE CASCADE;
create table FEE_SCHEDULE (
  id SERIAL,
  is_default boolean NOT NULL DEFAULT ('f'),
  coupon_code text,
  months_free int NOT NULL DEFAULT (0),
  monthly_rate decimal (10,2) NOT NULL,
  start_date TIMESTAMP,
  end_date TIMESTAMP,
  PRIMARY KEY (id)
);

INSERT INTO FEE_SCHEDULE (is_default, coupon_code, months_free, monthly_rate) values ('t', NULL, 1, 27.00, NULL, NULL);
INSERT INTO FEE_SCHEDULE (is_default, coupon_code, months_free, monthly_rate) values ('f', 'ASeB001', 4, 27.00, NULL, NULL);

drop table AUDIT_TRAIL;
create table AUDIT_TRAIL (
	entry_date	timestamp,
	victim_id	int,
	message		text,
	audit_trail_id  serial
);

drop table SYSTEM_MESSAGES;
create table SYSTEM_MESSAGES (
	system_message_id serial,
	entry_date timestamp,
	message text,
	display boolean NOT NULL DEFAULT ('t'),
	PRIMARY KEY (system_message_id)
);

drop table invites;
create table invites (
	invite_id serial,
	buzz_user_id int,
	invite_name text,
	invite_email text,
	invite_date	timestamp,
	invite_status text,
	nomoreemail boolean
);

drop table ebay;
create table ebay (
	buzz_user_id int,
	ebay_auth text,
	ebay_username text UNIQUE,
	entry_date timestamp,
    ebay_exp_date timestamp,
	primary key (buzz_user_id)
);

drop table seller_profile;
create table seller_profile ( 
	buzz_user_id int PRIMARY KEY, 
	category_id int REFERENCES seller_category(id) ON DELETE SET NULL, 
	fee_schedule_id int REFERENCES fee_schedule(id) ON DELETE SET NULL, 
	description TEXT,
	subscription_active BOOLEAN DEFAULT ('f'),
	subscription_id text,
	subscription_start_date timestamp,
	subscription_ended_date timestamp,
	subscription_signup_nonce text
);

drop index seller_profile_cat_index;
create index seller_profile_cat_index on seller_profile(category_id);

drop table seller_fee;
create table seller_fee (  -- NEW TABLE
  id            SERIAL,
  seller_id     INT,
  purchase_id   INT,
  amount        NUMERIC(10,2),
  date_sent     TIMESTAMP default NULL,
  invoice_paid  BOOLEAN default 'false',
  paypal_trans_id TEXT default NULL,
  invoice_sent boolean default 'false',
  PRIMARY KEY (id)
);

create index unprocessed_seller_fee_idx on seller_fee (date_sent);
create index unpaid_seller_fee_idx on seller_fee (invoice_paid);
create index paypal_trans_idx on seller_fee (paypal_trans_id);

drop table open_comm;
create table open_comm (  -- NEW TABLE
  id            SERIAL,
  buzz_user_id  INT UNIQUE,
  purchase_id   INT,
  referral_id   INT NOT NULL REFERENCES referral(id) ON DELETE CASCADE,
  amount        NUMERIC(10,2),
  payable       BOOLEAN NOT NULL DEFAULT 'false',
  PRIMARY KEY (id)
);

create index payable_commissions_idx on open_comm (payable);


drop table admin_time_table;
create table admin_time_table (
	id		serial,
	showText	text,
	numDays		int
);

Insert into admin_time_table (showText, numDays) Values ('Last 30 Days', 30);
Insert into admin_time_table (showText, numDays) Values ('Last 60 Days', 60);
Insert into Admin_time_table (showText, numDays) Values ('Last 90 Days', 90);

drop table pay_type;
create table pay_type (
	id		serial,
	showText	text
);

Insert into pay_type (showText) values ('percent');
Insert into pay_type (showText) values ('flatrate');

drop table limit_type;
create table limit_type (
	id		serial,
	showText	text
);

Insert into limit_type (showText) values ('days');
Insert into limit_type (showText) values ('purchases');


DROP TABLE email_delivery;
CREATE TABLE email_delivery (
  id SERIAL PRIMARY KEY,
  buzz_user_id int4 NOT NULL REFERENCES buzz_user(id),
  deliver_after timestamp NOT NULL,
  email_body text,
  email_subject text,
  in_progress boolean NOT NULL DEFAULT('f')
);

create index email_delivery_time_idx on email_delivery (deliver_after);
create index email_delivery_user_idx on email_delivery (buzz_user_id);
