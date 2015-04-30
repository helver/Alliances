
create table BUZZ_USER (
  id		serial,
  email		varchar(70) NOT NULL UNIQUE,
  username	varchar(70) NOT NULL UNIQUE,
  password	text NOT NULL,
  admin_code    int NOT NULL DEFAULT 0,
  last_auth     timestamp,
  primary key (id)
);

create index username_key on BUZZ_USER (username);
create index usernameEmail_key on BUZZ_USER (email);

create table UNCONFIRMED_USER (
  email		text,
  username	text,
  password	text,
  token		text
);

create index unconfirmed_user_index on UNCONFIRMED_USER (token);

create table BUZZ_USER_PROFILE (
  buzz_user_id	int,
  description	text,
  email_pref	int NOT NULL DEFAULT 1,
  primary key (buzz_user_id)
);

create table USER_PROFILE_MESGS (
  buzz_user_id  int,
  message	text,
  date_added	timestamp
);

create index profile_mesg_index on USER_PROFILE_MESGS (buzz_user_id);

create table ADMIN_LEVEL (
  code		int,
  value		text,
  primary key (code)
);

insert into ADMIN_LEVEL (code, value) VALUES (0, 'user');
insert into ADMIN_LEVEL (code, value) VALUES (1, 'admin');
insert into ADMIN_LEVEL (code, value) VALUES (2, 'superuser');

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

create table BLOCKED_EMAILS (
  to_id		int,
  from_id	int
);

create index blocked_email_from_index on BLOCKED_EMAILS (from_id);
create index blocked_email_to_index on BLOCKED_EMAILS (to_id);

create table SUSPENDED_USER (
  id		int NOT NULL UNIQUE,
  email		text NOT NULL UNIQUE,
  username      text NOT NULL UNIQUE,
  password      text,
  admin_code    int,
  email_pref    int,
  primary key (id)
);

create table SELLER_INFO (
  buzz_user_id	int,
  category_id   int,
  feedback	int,
  positive_pct	decimal (5,2),
  powerseller	boolean NOT NULL DEFAULT ('false'),
 primary key (buzz_user_id)
);

create index seller_category_index on SELLER_INFO (category_id);

-- account for possibility that seller is in multiple categories

create table SELLER_CATEGORY (
  id		serial,
  name		text,
  description	text,
  primary key (id)
);

create index seller_cat_list_index on SELLER_CATEGORY (name);

create table HIVE (
  buzz_user_id	int,
  member_id	int,
  date_added	timestamp
);

create index hive_user_index on HIVE (buzz_user_id);

create table HONEYCOMB (
  buzz_user_id	int,
  member_id	int,
  date_added	timestamp
);

create index honeycomb_user_index on HONEYCOMB (buzz_user_id);

create table REFERRAL (
  id		serial,
  buzz_user_id	int,
  refer_user_id	int,
  seller_id	int,
  expiration	timestamp,
  date_added	timestamp,
  PRIMARY KEY (id)
);

create index REFERRAL_BUYER_INDEX on REFERRAL (buzz_user_id);
create index REFERRAL_SELLER_INDEX on REFERRAL (seller_id);

create table PAYPAL (
  buzz_user_id	int,
-- need paypal info here
  PRIMARY KEY (buzz_user_id)
);

create table RECOMMENDATION (
  buzz_user_id	int,
  seller_id	int,
  num_purchases	int,
  speed_rating	int,
  expect_rating	int,
  value_rating	int,
  comm_rating	int,
  exp_rating	int,
  recommend	text
);

create index SELLER_RECOMMEND_INDEX on RECOMMENDATION (seller_id);
create index BUYER_RECOMMDEND_INDEX on RECOMMENDATION (buyer_id);

create table PURCHASES (
  id		serial,
  buyer_id	int,
  seller_id	int,
  referral_id	int, -- foreign key
  trans_date	timestamp,
  amount	decimal (10,2),
  cleared	boolean NOT NULL DEFAULT 'false',
  paid		boolean NOT NULL DEFAULT 'false',
  PRIMARY KEY (id)
);

create index CLEARED_PURCHASES_INDEX on PURCHASES (cleared, trans_date);
create index PAID_PURCHASES_INDEX on PURCHASES (paid, trans_date);

create table PAID_COMMS (
  seller_id	int,
  payee_id	int,
  referral_id	int, -- foreign key
  purchase_id	int, -- foreign key
  paid_date	timestamp,
  amount	decimal (10,2)
);

create index PAYEE_COMMS_INDEX on PAID_COMMS (payee_id);

create table COMMISSION_SCHEDULE (
  seller_id	int,
  referal_id	int,
  refer_cut_pct	decimal (5,2),
  refer_cut_amt	decimal (10,2),
  buyer_cut_pct	decimal (5,2),
  buyer_cut_amt decimal (10,2),
  buyer_cut_thr decimal (10,2),
  add_date	timestamp,
  duration_days int,
  remaining_days int,
  original_purch_limit	int,
  remaining_purchases	int,
   
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
);

create index COMM_SCHED_INDEX on COMMISSION_SCHEDULE (seller_id);

create table FEE_SCHEDULE (
  seller_id	int NOT NULL,
  amount_due	decimal (10,2),
  frequency	int,
  last_paid_dt	timestamp,
  next_due_dt	timestamp,
  last_paid_amt	decimal (10,2),
  overdue	decimal (10,2) NOT NULL DEFAULT ('0.00')
);

create index FEE_SCHED_INDEX on FEE_SCHEDULE (seller_id);

create table FEE_FREQUENCY (
  code		int,
  value		text
);

insert into FEE_FREQUENCY (code, value) VALUES (0, 'none');
insert into FEE_FREQUENCY (code, value) VALUES (1, 'monthly');
insert into FEE_FREQUENCY (code, value) VALUES (2, 'quarterly');
insert into FEE_FREQUENCY (code, value) VALUES (3, 'bi-annually');
insert into FEE_FREQUENCY (code, value) VALUES (4, 'annually');
