--
-- PostgreSQL database dump
--

SET client_encoding = 'SQL_ASCII';
SET check_function_bodies = false;

SET SESSION AUTHORIZATION 'postgres';

--
-- TOC entry 2 (OID 0)
-- Name: aswas; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE aswas WITH TEMPLATE = template0 ENCODING = 'SQL_ASCII';


\connect aswas postgres

SET client_encoding = 'SQL_ASCII';
SET check_function_bodies = false;

--
-- TOC entry 4 (OID 2200)
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


SET SESSION AUTHORIZATION 'aswas';

SET search_path = public, pg_catalog;

--
-- TOC entry 9 (OID 2073408)
-- Name: buzz_user; Type: TABLE; Schema: public; Owner: aswas
--

CREATE TABLE buzz_user (
    id serial NOT NULL,
    email character varying(70) NOT NULL,
    username character varying(70) NOT NULL,
    "password" text NOT NULL,
    admin_code integer DEFAULT 0 NOT NULL,
    last_auth timestamp without time zone
);


--
-- TOC entry 10 (OID 2073423)
-- Name: unconfirmed_user; Type: TABLE; Schema: public; Owner: aswas
--

CREATE TABLE unconfirmed_user (
    email text,
    username text,
    "password" text,
    token text
);


--
-- TOC entry 11 (OID 2073437)
-- Name: user_profile_mesgs; Type: TABLE; Schema: public; Owner: aswas
--

CREATE TABLE user_profile_mesgs (
    buzz_user_id integer,
    message text,
    date_added timestamp without time zone
);


--
-- TOC entry 12 (OID 2073443)
-- Name: admin_level; Type: TABLE; Schema: public; Owner: aswas
--

CREATE TABLE admin_level (
    code integer NOT NULL,
    value text
);


--
-- TOC entry 13 (OID 2073453)
-- Name: email_freq; Type: TABLE; Schema: public; Owner: aswas
--

CREATE TABLE email_freq (
    preference integer NOT NULL,
    value text
);


--
-- TOC entry 14 (OID 2073465)
-- Name: blocked_emails; Type: TABLE; Schema: public; Owner: aswas
--

CREATE TABLE blocked_emails (
    to_id integer,
    from_id integer
);


--
-- TOC entry 15 (OID 2073469)
-- Name: suspended_user; Type: TABLE; Schema: public; Owner: aswas
--

CREATE TABLE suspended_user (
    id integer NOT NULL,
    email text NOT NULL,
    username text NOT NULL,
    "password" text,
    admin_code integer,
    email_pref integer
);


--
-- TOC entry 16 (OID 2073482)
-- Name: seller_category; Type: TABLE; Schema: public; Owner: aswas
--

CREATE TABLE seller_category (
    id serial NOT NULL,
    name text,
    description text
);


--
-- TOC entry 17 (OID 2073491)
-- Name: hive; Type: TABLE; Schema: public; Owner: aswas
--

CREATE TABLE hive (
    buzz_user_id integer,
    member_id integer,
    date_added timestamp without time zone
);


--
-- TOC entry 18 (OID 2073494)
-- Name: honeycomb; Type: TABLE; Schema: public; Owner: aswas
--

CREATE TABLE honeycomb (
    buzz_user_id integer,
    member_id integer,
    date_added timestamp without time zone
);


--
-- TOC entry 19 (OID 2073499)
-- Name: referral; Type: TABLE; Schema: public; Owner: aswas
--

CREATE TABLE referral (
    id serial NOT NULL,
    buzz_user_id integer,
    refer_user_id integer,
    seller_id integer,
    expiration timestamp without time zone,
    date_added timestamp without time zone
);


--
-- TOC entry 20 (OID 2073518)
-- Name: purchases; Type: TABLE; Schema: public; Owner: aswas
--

CREATE TABLE purchases (
    id serial NOT NULL,
    buyer_id integer,
    seller_id integer,
    referral_id integer,
    trans_date timestamp without time zone,
    amount numeric(10,2),
    cleared boolean DEFAULT false NOT NULL,
    paid boolean DEFAULT false NOT NULL
);


--
-- TOC entry 21 (OID 2073527)
-- Name: paid_comms; Type: TABLE; Schema: public; Owner: aswas
--

CREATE TABLE paid_comms (
    seller_id integer,
    payee_id integer,
    referral_id integer,
    purchase_id integer,
    paid_date timestamp without time zone,
    amount numeric(10,2)
);


--
-- TOC entry 22 (OID 2073533)
-- Name: fee_schedule; Type: TABLE; Schema: public; Owner: aswas
--

CREATE TABLE fee_schedule (
    seller_id integer NOT NULL,
    amount_due numeric(10,2),
    frequency integer,
    last_paid_dt timestamp without time zone,
    next_due_dt timestamp without time zone,
    last_paid_amt numeric(10,2),
    overdue numeric(10,2) DEFAULT 0.00 NOT NULL
);


--
-- TOC entry 23 (OID 2073537)
-- Name: fee_frequency; Type: TABLE; Schema: public; Owner: aswas
--

CREATE TABLE fee_frequency (
    code integer,
    value text
);


--
-- TOC entry 24 (OID 2073547)
-- Name: seller_info; Type: TABLE; Schema: public; Owner: aswas
--

CREATE TABLE seller_info (
    buzz_user_id integer NOT NULL,
    category_id integer,
    feedback integer,
    positive_pct numeric(5,2),
    powerseller boolean DEFAULT false NOT NULL
);


--
-- TOC entry 25 (OID 2073599)
-- Name: buzz_user_profile; Type: TABLE; Schema: public; Owner: aswas
--

CREATE TABLE buzz_user_profile (
    buzz_user_id integer NOT NULL,
    description text,
    email_pref integer DEFAULT 1 NOT NULL
);


--
-- TOC entry 26 (OID 2073701)
-- Name: audit_trail; Type: TABLE; Schema: public; Owner: aswas
--

CREATE TABLE audit_trail (
    entry_date timestamp without time zone,
    victim_id integer,
    message text,
    audit_trail_id integer
);


--
-- TOC entry 27 (OID 2073706)
-- Name: system_messages; Type: TABLE; Schema: public; Owner: aswas
--

CREATE TABLE system_messages (
    entry_date timestamp without time zone,
    message text,
    system_message_id integer
);


--
-- TOC entry 28 (OID 2073755)
-- Name: invites; Type: TABLE; Schema: public; Owner: aswas
--

CREATE TABLE invites (
    invite_id serial NOT NULL,
    buzz_user_id integer,
    invite_name text,
    invite_email text,
    invite_date timestamp without time zone,
    invite_status text
);


--
-- TOC entry 29 (OID 2073972)
-- Name: ebay; Type: TABLE; Schema: public; Owner: aswas
--

CREATE TABLE ebay (
    buzz_user_id integer NOT NULL,
    ebay_auth text,
    entry_date timestamp without time zone
);


--
-- TOC entry 5 (OID 2074048)
-- Name: system_messages_seq; Type: SEQUENCE; Schema: public; Owner: aswas
--

CREATE SEQUENCE system_messages_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 7 (OID 2074050)
-- Name: audit_trail_seq; Type: SEQUENCE; Schema: public; Owner: aswas
--

CREATE SEQUENCE audit_trail_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- TOC entry 30 (OID 2074709)
-- Name: recommendation; Type: TABLE; Schema: public; Owner: aswas
--

CREATE TABLE recommendation (
    reco_id serial NOT NULL,
    buzz_user_id integer,
    seller_id integer,
    num_purchases integer,
    speed_rating integer,
    expect_rating integer,
    value_rating integer,
    comm_rating integer,
    exp_rating integer,
    recommend text
);


--
-- TOC entry 31 (OID 2075150)
-- Name: paypal; Type: TABLE; Schema: public; Owner: aswas
--

CREATE TABLE paypal (
    id serial NOT NULL,
    buzz_user_id integer,
    invoice_sent integer,
    paid_invoice integer,
    amount numeric(10,2),
    sold_to_id integer,
    full_name_to text,
    email_addr_to text
);


--
-- TOC entry 32 (OID 2075168)
-- Name: paypal_trans; Type: TABLE; Schema: public; Owner: aswas
--

CREATE TABLE paypal_trans (
    id serial NOT NULL,
    buzz_user_id integer,
    commission_seller_id integer,
    sold_to_id integer,
    email_add_to text,
    full_name_to text,
    commisssion_paid integer
);


--
-- TOC entry 33 (OID 2075375)
-- Name: ebay_bk; Type: TABLE; Schema: public; Owner: aswas
--

CREATE TABLE ebay_bk (
    buzz_user_id integer,
    ebay_auth text,
    entry_date timestamp without time zone
);


--
-- TOC entry 34 (OID 2075409)
-- Name: commission_schedule; Type: TABLE; Schema: public; Owner: aswas
--

CREATE TABLE commission_schedule (
    id bigserial NOT NULL,
    buzz_user_id integer,
    comm_level integer,
    active boolean,
    amount numeric(10,2),
    max_limit integer,
    remain integer,
    min_pay_threshold numeric(10,2) DEFAULT 0.0,
    max_amount numeric(10,2) DEFAULT 0.0,
    pay_type text,
    limit_type text,
    add_date timestamp without time zone
);


--
-- Data for TOC entry 82 (OID 2073408)
-- Name: buzz_user; Type: TABLE DATA; Schema: public; Owner: aswas
--

COPY buzz_user (id, email, username, "password", admin_code, last_auth) FROM stdin;
2	TheMan@email.com	TheMan	foo	2	\N
3	NoBody@email.com	NoBody	foo	2	\N
4	topSeller@email.com	topSeller	foo	2	\N
5	MiddleSeller@email.com	MiddleSeller	foo	2	\N
6	BottomSeller@email.com	BottomSeller	foo	2	\N
1	foo@bar2.com	nick	nick	1	\N
15	eric@alliances.org	helver	abc123	1	\N
17	deb@aswas.com	aswas	aswas2772	1	\N
16	helver@alliances.org	eric	abc123	1	\N
18	ehelvey@yahoo.com	asdfasdf	abc123	1	\N
\.


--
-- Data for TOC entry 83 (OID 2073423)
-- Name: unconfirmed_user; Type: TABLE DATA; Schema: public; Owner: aswas
--

COPY unconfirmed_user (email, username, "password", token) FROM stdin;
ehelvey@yahoo.com	joeSchmuckatella	joe	joeSchmuckatella
\.


--
-- Data for TOC entry 84 (OID 2073437)
-- Name: user_profile_mesgs; Type: TABLE DATA; Schema: public; Owner: aswas
--

COPY user_profile_mesgs (buzz_user_id, message, date_added) FROM stdin;
15	helver added NoBody as a new Hive Member.	2007-04-30 23:04:55.851359
15	helver added NoBody as a new Hive Member.	2007-04-30 23:04:55.859579
15	helver added NoBody as a new Hive Member.	2007-04-30 23:04:55.865562
15	helver added NoBody as a new Hive Member.	2007-04-30 23:04:55.871562
15	helver removed BottomSeller as a Hive Member.	2007-04-30 23:32:04.975608
15	helver removed BottomSeller as a Hive Member.	2007-04-30 23:32:04.98283
15	helver removed BottomSeller as a Hive Member.	2007-04-30 23:32:04.989078
15	helver removed eric as a Hive Member.	2007-04-30 23:33:39.30049
15	helver removed eric as a Hive Member.	2007-04-30 23:33:39.312137
15	helver removed NoBody as a Hive Member.	2007-04-30 23:35:55.161
1	helver added eric as a new Hive Member.	2007-04-30 23:44:43.037337
1	helver added topSeller as a new Hive Member.	2007-04-30 23:47:24.186554
16	helver added topSeller as a new Hive Member.	2007-04-30 23:47:24.197421
4	nick added asdfasdf as a new Hive Member.	2007-05-06 22:46:00.945392
15	nick added asdfasdf as a new Hive Member.	2007-05-06 22:46:00.949334
16	nick added asdfasdf as a new Hive Member.	2007-05-06 22:46:00.955588
1	helver removed topSeller as a Hive Member.	2007-05-08 21:16:33.14433
16	helver removed topSeller as a Hive Member.	2007-05-08 21:16:33.148443
1	helver added topSeller as a new Hive Member.	2007-05-08 21:16:49.02128
16	helver added topSeller as a new Hive Member.	2007-05-08 21:16:49.030477
1	helver removed topSeller as a Hive Member.	2007-05-08 21:17:10.981754
16	helver removed topSeller as a Hive Member.	2007-05-08 21:17:10.989925
1	helver added topSeller as a new Hive Member.	2007-05-08 21:17:16.604832
16	helver added topSeller as a new Hive Member.	2007-05-08 21:17:16.611748
1	helver removed topSeller as a Hive Member.	2007-05-11 13:50:46.022148
16	helver removed topSeller as a Hive Member.	2007-05-11 13:50:46.028037
\.


--
-- Data for TOC entry 85 (OID 2073443)
-- Name: admin_level; Type: TABLE DATA; Schema: public; Owner: aswas
--

COPY admin_level (code, value) FROM stdin;
1	admin
2	superuser
0	user
\.


--
-- Data for TOC entry 86 (OID 2073453)
-- Name: email_freq; Type: TABLE DATA; Schema: public; Owner: aswas
--

COPY email_freq (preference, value) FROM stdin;
0	never
1	immediate
3	weekly
4	monthly
2	Daily
\.


--
-- Data for TOC entry 87 (OID 2073465)
-- Name: blocked_emails; Type: TABLE DATA; Schema: public; Owner: aswas
--

COPY blocked_emails (to_id, from_id) FROM stdin;
1	6
1	5
\.


--
-- Data for TOC entry 88 (OID 2073469)
-- Name: suspended_user; Type: TABLE DATA; Schema: public; Owner: aswas
--

COPY suspended_user (id, email, username, "password", admin_code, email_pref) FROM stdin;
\.


--
-- Data for TOC entry 89 (OID 2073482)
-- Name: seller_category; Type: TABLE DATA; Schema: public; Owner: aswas
--

COPY seller_category (id, name, description) FROM stdin;
1	new cat	new cat
\.


--
-- Data for TOC entry 90 (OID 2073491)
-- Name: hive; Type: TABLE DATA; Schema: public; Owner: aswas
--

COPY hive (buzz_user_id, member_id, date_added) FROM stdin;
15	1	2007-04-27 23:55:35.238692
1	16	2007-04-27 23:56:07.654443
1	4	2007-04-28 00:05:56.182879
17	15	2007-04-28 01:17:42.194269
17	6	2007-04-28 01:18:25.284932
1	15	2007-04-29 22:32:02.550128
15	16	2007-04-30 23:44:43.03484
1	18	2007-05-06 22:46:00.94271
\.


--
-- Data for TOC entry 91 (OID 2073494)
-- Name: honeycomb; Type: TABLE DATA; Schema: public; Owner: aswas
--

COPY honeycomb (buzz_user_id, member_id, date_added) FROM stdin;
1	4	2007-03-06 00:00:00
1	5	2007-03-06 00:00:00
1	6	2007-03-06 00:00:00
\.


--
-- Data for TOC entry 92 (OID 2073499)
-- Name: referral; Type: TABLE DATA; Schema: public; Owner: aswas
--

COPY referral (id, buzz_user_id, refer_user_id, seller_id, expiration, date_added) FROM stdin;
1	4	1	3	2007-12-01 00:00:00	2007-03-01 00:00:00
7	1	4	1	\N	2007-05-13 22:53:02.11669
8	1	6	1	\N	2007-05-13 22:53:02.119732
\.


--
-- Data for TOC entry 93 (OID 2073518)
-- Name: purchases; Type: TABLE DATA; Schema: public; Owner: aswas
--

COPY purchases (id, buyer_id, seller_id, referral_id, trans_date, amount, cleared, paid) FROM stdin;
1	99	1	1	2007-02-01 00:00:00	120.87	f	f
\.


--
-- Data for TOC entry 94 (OID 2073527)
-- Name: paid_comms; Type: TABLE DATA; Schema: public; Owner: aswas
--

COPY paid_comms (seller_id, payee_id, referral_id, purchase_id, paid_date, amount) FROM stdin;
1	4	1	2	2006-03-07 00:00:00	25.99
3	1	5	4	2006-03-01 00:00:00	17.98
\.


--
-- Data for TOC entry 95 (OID 2073533)
-- Name: fee_schedule; Type: TABLE DATA; Schema: public; Owner: aswas
--

COPY fee_schedule (seller_id, amount_due, frequency, last_paid_dt, next_due_dt, last_paid_amt, overdue) FROM stdin;
\.


--
-- Data for TOC entry 96 (OID 2073537)
-- Name: fee_frequency; Type: TABLE DATA; Schema: public; Owner: aswas
--

COPY fee_frequency (code, value) FROM stdin;
0	none
1	monthly
2	quarterly
3	bi-annually
4	Annually
\.


--
-- Data for TOC entry 97 (OID 2073547)
-- Name: seller_info; Type: TABLE DATA; Schema: public; Owner: aswas
--

COPY seller_info (buzz_user_id, category_id, feedback, positive_pct, powerseller) FROM stdin;
1	\N	\N	\N	f
16	\N	\N	\N	f
\.


--
-- Data for TOC entry 98 (OID 2073599)
-- Name: buzz_user_profile; Type: TABLE DATA; Schema: public; Owner: aswas
--

COPY buzz_user_profile (buzz_user_id, description, email_pref) FROM stdin;
2		1
3		1
4		1
5		1
6		1
17		1
16		1
15		3
18		1
1	Nick is a good guy and this is his kicking butt type profile-y thing.	1
\.


--
-- Data for TOC entry 99 (OID 2073701)
-- Name: audit_trail; Type: TABLE DATA; Schema: public; Owner: aswas
--

COPY audit_trail (entry_date, victim_id, message, audit_trail_id) FROM stdin;
\.


--
-- Data for TOC entry 100 (OID 2073706)
-- Name: system_messages; Type: TABLE DATA; Schema: public; Owner: aswas
--

COPY system_messages (entry_date, message, system_message_id) FROM stdin;
\.


--
-- Data for TOC entry 101 (OID 2073755)
-- Name: invites; Type: TABLE DATA; Schema: public; Owner: aswas
--

COPY invites (invite_id, buzz_user_id, invite_name, invite_email, invite_date, invite_status) FROM stdin;
1	1	Foo Man	FooMan@choo.com	2007-03-15 00:00:00	Pending
6	1	Nick Swank4	nswank@gmail.com	2007-03-17 22:20:45.629684	'Pending'
7	1	Nic Swank5	nswank@gmail.com	2007-03-17 22:23:08.634746	'Pending'
\.


--
-- Data for TOC entry 102 (OID 2073972)
-- Name: ebay; Type: TABLE DATA; Schema: public; Owner: aswas
--

COPY ebay (buzz_user_id, ebay_auth, entry_date) FROM stdin;
1	this is my ebay auth	2007-04-03 22:48:22.655486
2	AgAAAA**AQAAAA**aAAAAA**gdAjRg**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4CnC5KGogWdj6x9nY+seQ**pacAAA**AAMAAA**KJsihUakmXzZPsXF2Uv6FH1kKiU4Sx7isA1V6DxQAIwys+v9TqyC3qzgkUjGi2SonecSVcUjnisijiXmOtJbETE5hdTCBZJ/zwdVWN2I0zKNaQ7HJhM1KDXbR85e1BGjhCaPhEvvX/7+atB7/itsh/iRGiJtMdZkVG3kJZxr9hav3u+W1QkUNi2aYRd84xWwNRy/VLWoJgy3PS62dF7uBNWkibfDnZgTRihPJC23lBfJpHvUgdURDdIKCzv/1kPzjvxzaLDyZriNptAa+6aCsLGwY6d4vcm9ygAqcJ5sv+iQlKab9BZXZkN1E0W50an4VZDqNY4n3z+MYSv7YluU6qvZNv0zuP/apQNdC1an8UZRLNr+p+79IAXP+gLWlLAWFLDtgpj2ypTuuDt7mnyWUOhYasD8+qPxTrpSTH/cjmLfcBScMDwbMGUIrEOlfscqbxEzVRrIY4r8/4Mkpl3NpGjN3WHeSb7oxUBi2om+9FYTiPkIB8KhURriuUnF+rjfrT8ODEcR7Q1mGgbsPgAd8tVbNzoSxb1eK8FehkjAeZwlpUHhBwDDyzmoc1ezMKHbxBpn6aMj0RuC+I/PYkXBH3YNtgCRpZzRhX15rliCWxo7GNalQ0glvLjptjsqWo7P//2Qm1usK5qW5VJOMaLUmoN1waRjrLFL5PKJGoOEfoQpR2B3CnrMCbxAZqDQehX8k2UPQmw+EtdlMwXUKlxsKiebx00jH4djiWyyJoSq6k45jj2LOB8lmLQYGw8uG467	2007-04-18 00:00:00
\.


--
-- Data for TOC entry 103 (OID 2074709)
-- Name: recommendation; Type: TABLE DATA; Schema: public; Owner: aswas
--

COPY recommendation (reco_id, buzz_user_id, seller_id, num_purchases, speed_rating, expect_rating, value_rating, comm_rating, exp_rating, recommend) FROM stdin;
1	1	3	55	3	4	3	5	7	Good Guy.  A little slow.
3	1	15	\N	\N	\N	\N	\N	\N	\N
4	1	6	5	4	1	3	1	4	Foo bar
\.


--
-- Data for TOC entry 104 (OID 2075150)
-- Name: paypal; Type: TABLE DATA; Schema: public; Owner: aswas
--

COPY paypal (id, buzz_user_id, invoice_sent, paid_invoice, amount, sold_to_id, full_name_to, email_addr_to) FROM stdin;
\.


--
-- Data for TOC entry 105 (OID 2075168)
-- Name: paypal_trans; Type: TABLE DATA; Schema: public; Owner: aswas
--

COPY paypal_trans (id, buzz_user_id, commission_seller_id, sold_to_id, email_add_to, full_name_to, commisssion_paid) FROM stdin;
\.


--
-- Data for TOC entry 106 (OID 2075375)
-- Name: ebay_bk; Type: TABLE DATA; Schema: public; Owner: aswas
--

COPY ebay_bk (buzz_user_id, ebay_auth, entry_date) FROM stdin;
1	this is my ebay auth	2007-04-03 22:48:22.655486
2	AgAAAA**AQAAAA**aAAAAA**gdAjRg**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4CnC5KGogWdj6x9nY+seQ**pacAAA**AAMAAA**KJsihUakmXzZPsXF2Uv6FH1kKiU4Sx7isA1V6DxQAIwys+v9TqyC3qzgkUjGi2SonecSVcUjnisijiXmOtJbETE5hdTCBZJ/zwdVWN2I0zKNaQ7HJhM1KDXbR85e1BGjhCaPhEvvX/7+atB7/itsh/iRGiJtMdZkVG3kJZxr9hav3u+W1QkUNi2aYRd84xWwNRy/VLWoJgy3PS62dF7uBNWkibfDnZgTRihPJC23lBfJpHvUgdURDdIKCzv/1kPzjvxzaLDyZriNptAa+6aCsLGwY6d4vcm9ygAqcJ5sv+iQlKab9BZXZkN1E0W50an4VZDqNY4n3z+MYSv7YluU6qvZNv0zuP/apQNdC1an8UZRLNr+p+79IAXP+gLWlLAWFLDtgpj2ypTuuDt7mnyWUOhYasD8+qPxTrpSTH/cjmLfcBScMDwbMGUIrEOlfscqbxEzVRrIY4r8/4Mkpl3NpGjN3WHeSb7oxUBi2om+9FYTiPkIB8KhURriuUnF+rjfrT8ODEcR7Q1mGgbsPgAd8tVbNzoSxb1eK8FehkjAeZwlpUHhBwDDyzmoc1ezMKHbxBpn6aMj0RuC+I/PYkXBH3YNtgCRpZzRhX15rliCWxo7GNalQ0glvLjptjsqWo7P//2Qm1usK5qW5VJOMaLUmoN1waRjrLFL5PKJGoOEfoQpR2B3CnrMCbxAZqDQehX8k2UPQmw+EtdlMwXUKlxsKiebx00jH4djiWyyJoSq6k45jj2LOB8lmLQYGw8uG467	2007-04-18 00:00:00
2	AgAAAA**AQAAAA**aAAAAA**gdAjRg**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4CnC5KGogWdj6x9nY+seQ**pacAAA**AAMAAA**KJsihUakmXzZPsXF2Uv6FH1kKiU4Sx7isA1V6DxQAIwys+v9TqyC3qzgkUjGi2SonecSVcUjnisijiXmOtJbETE5hdTCBZJ/zwdVWN2I0zKNaQ7HJhM1KDXbR85e1BGjhCaPhEvvX/7+atB7/itsh/iRGiJtMdZkVG3kJZxr9hav3u+W1QkUNi2aYRd84xWwNRy/VLWoJgy3PS62dF7uBNWkibfDnZgTRihPJC23lBfJpHvUgdURDdIKCzv/1kPzjvxzaLDyZriNptAa+6aCsLGwY6d4vcm9ygAqcJ5sv+iQlKab9BZXZkN1E0W50an4VZDqNY4n3z+MYSv7YluU6qvZNv0zuP/apQNdC1an8UZRLNr+p+79IAXP+gLWlLAWFLDtgpj2ypTuuDt7mnyWUOhYasD8+qPxTrpSTH/cjmLfcBScMDwbMGUIrEOlfscqbxEzVRrIY4r8/4Mkpl3NpGjN3WHeSb7oxUBi2om+9FYTiPkIB8KhURriuUnF+rjfrT8ODEcR7Q1mGgbsPgAd8tVbNzoSxb1eK8FehkjAeZwlpUHhBwDDyzmoc1ezMKHbxBpn6aMj0RuC+I/PYkXBH3YNtgCRpZzRhX15rliCWxo7GNalQ0glvLjptjsqWo7P//2Qm1usK5qW5VJOMaLUmoN1waRjrLFL5PKJGoOEfoQpR2B3CnrMCbxAZqDQehX8k2UPQmw+EtdlMwXUKlxsKiebx00jH4djiWyyJoSq6k45jj2LOB8lmLQYGw8uG467	2007-04-18 00:00:00
\.


--
-- Data for TOC entry 107 (OID 2075409)
-- Name: commission_schedule; Type: TABLE DATA; Schema: public; Owner: aswas
--

COPY commission_schedule (id, buzz_user_id, comm_level, active, amount, max_limit, remain, min_pay_threshold, max_amount, pay_type, limit_type, add_date) FROM stdin;
\.


--
-- TOC entry 48 (OID 2073422)
-- Name: usernameemail_key; Type: INDEX; Schema: public; Owner: aswas
--

CREATE INDEX usernameemail_key ON buzz_user USING btree (email);


--
-- TOC entry 50 (OID 2073428)
-- Name: unconfirmed_user_index; Type: INDEX; Schema: public; Owner: aswas
--

CREATE INDEX unconfirmed_user_index ON unconfirmed_user USING btree (token);


--
-- TOC entry 51 (OID 2073442)
-- Name: profile_mesg_index; Type: INDEX; Schema: public; Owner: aswas
--

CREATE INDEX profile_mesg_index ON user_profile_mesgs USING btree (buzz_user_id);


--
-- TOC entry 54 (OID 2073467)
-- Name: blocked_email_from_index; Type: INDEX; Schema: public; Owner: aswas
--

CREATE INDEX blocked_email_from_index ON blocked_emails USING btree (from_id);


--
-- TOC entry 55 (OID 2073468)
-- Name: blocked_email_to_index; Type: INDEX; Schema: public; Owner: aswas
--

CREATE INDEX blocked_email_to_index ON blocked_emails USING btree (to_id);


--
-- TOC entry 59 (OID 2073490)
-- Name: seller_cat_list_index; Type: INDEX; Schema: public; Owner: aswas
--

CREATE INDEX seller_cat_list_index ON seller_category USING btree (name);


--
-- TOC entry 61 (OID 2073493)
-- Name: hive_user_index; Type: INDEX; Schema: public; Owner: aswas
--

CREATE INDEX hive_user_index ON hive USING btree (buzz_user_id);


--
-- TOC entry 63 (OID 2073496)
-- Name: honeycomb_user_index; Type: INDEX; Schema: public; Owner: aswas
--

CREATE INDEX honeycomb_user_index ON honeycomb USING btree (buzz_user_id);


--
-- TOC entry 64 (OID 2073504)
-- Name: referral_buyer_index; Type: INDEX; Schema: public; Owner: aswas
--

CREATE INDEX referral_buyer_index ON referral USING btree (buzz_user_id);


--
-- TOC entry 66 (OID 2073505)
-- Name: referral_seller_index; Type: INDEX; Schema: public; Owner: aswas
--

CREATE INDEX referral_seller_index ON referral USING btree (seller_id);


--
-- TOC entry 67 (OID 2073525)
-- Name: cleared_purchases_index; Type: INDEX; Schema: public; Owner: aswas
--

CREATE INDEX cleared_purchases_index ON purchases USING btree (cleared, trans_date);


--
-- TOC entry 68 (OID 2073526)
-- Name: paid_purchases_index; Type: INDEX; Schema: public; Owner: aswas
--

CREATE INDEX paid_purchases_index ON purchases USING btree (paid, trans_date);


--
-- TOC entry 70 (OID 2073529)
-- Name: payee_comms_index; Type: INDEX; Schema: public; Owner: aswas
--

CREATE INDEX payee_comms_index ON paid_comms USING btree (payee_id);


--
-- TOC entry 71 (OID 2073536)
-- Name: fee_sched_index; Type: INDEX; Schema: public; Owner: aswas
--

CREATE INDEX fee_sched_index ON fee_schedule USING btree (seller_id);


--
-- TOC entry 47 (OID 2073607)
-- Name: username_key; Type: INDEX; Schema: public; Owner: aswas
--

CREATE INDEX username_key ON buzz_user USING btree (username);


--
-- TOC entry 49 (OID 2073700)
-- Name: userpassword_key; Type: INDEX; Schema: public; Owner: aswas
--

CREATE INDEX userpassword_key ON buzz_user USING btree ("password");


--
-- TOC entry 62 (OID 2074467)
-- Name: hive_user_member_index; Type: INDEX; Schema: public; Owner: aswas
--

CREATE INDEX hive_user_member_index ON hive USING btree (buzz_user_id, member_id);


--
-- TOC entry 76 (OID 2074717)
-- Name: seller_recommend_index; Type: INDEX; Schema: public; Owner: aswas
--

CREATE INDEX seller_recommend_index ON recommendation USING btree (seller_id);


--
-- TOC entry 79 (OID 2075419)
-- Name: active_commission; Type: INDEX; Schema: public; Owner: aswas
--

CREATE INDEX active_commission ON commission_schedule USING btree (active, comm_level, buzz_user_id);


--
-- TOC entry 81 (OID 2075420)
-- Name: seller_commission; Type: INDEX; Schema: public; Owner: aswas
--

CREATE INDEX seller_commission ON commission_schedule USING btree (buzz_user_id);


--
-- TOC entry 45 (OID 2073415)
-- Name: buzz_user_pkey; Type: CONSTRAINT; Schema: public; Owner: aswas
--

ALTER TABLE ONLY buzz_user
    ADD CONSTRAINT buzz_user_pkey PRIMARY KEY (id);


--
-- TOC entry 44 (OID 2073417)
-- Name: buzz_user_email_key; Type: CONSTRAINT; Schema: public; Owner: aswas
--

ALTER TABLE ONLY buzz_user
    ADD CONSTRAINT buzz_user_email_key UNIQUE (email);


--
-- TOC entry 46 (OID 2073419)
-- Name: buzz_user_username_key; Type: CONSTRAINT; Schema: public; Owner: aswas
--

ALTER TABLE ONLY buzz_user
    ADD CONSTRAINT buzz_user_username_key UNIQUE (username);


--
-- TOC entry 52 (OID 2073448)
-- Name: admin_level_pkey; Type: CONSTRAINT; Schema: public; Owner: aswas
--

ALTER TABLE ONLY admin_level
    ADD CONSTRAINT admin_level_pkey PRIMARY KEY (code);


--
-- TOC entry 53 (OID 2073458)
-- Name: email_freq_pkey; Type: CONSTRAINT; Schema: public; Owner: aswas
--

ALTER TABLE ONLY email_freq
    ADD CONSTRAINT email_freq_pkey PRIMARY KEY (preference);


--
-- TOC entry 57 (OID 2073474)
-- Name: suspended_user_pkey; Type: CONSTRAINT; Schema: public; Owner: aswas
--

ALTER TABLE ONLY suspended_user
    ADD CONSTRAINT suspended_user_pkey PRIMARY KEY (id);


--
-- TOC entry 56 (OID 2073476)
-- Name: suspended_user_email_key; Type: CONSTRAINT; Schema: public; Owner: aswas
--

ALTER TABLE ONLY suspended_user
    ADD CONSTRAINT suspended_user_email_key UNIQUE (email);


--
-- TOC entry 58 (OID 2073478)
-- Name: suspended_user_username_key; Type: CONSTRAINT; Schema: public; Owner: aswas
--

ALTER TABLE ONLY suspended_user
    ADD CONSTRAINT suspended_user_username_key UNIQUE (username);


--
-- TOC entry 60 (OID 2073488)
-- Name: seller_category_pkey; Type: CONSTRAINT; Schema: public; Owner: aswas
--

ALTER TABLE ONLY seller_category
    ADD CONSTRAINT seller_category_pkey PRIMARY KEY (id);


--
-- TOC entry 65 (OID 2073502)
-- Name: referral_pkey; Type: CONSTRAINT; Schema: public; Owner: aswas
--

ALTER TABLE ONLY referral
    ADD CONSTRAINT referral_pkey PRIMARY KEY (id);


--
-- TOC entry 69 (OID 2073523)
-- Name: purchases_pkey; Type: CONSTRAINT; Schema: public; Owner: aswas
--

ALTER TABLE ONLY purchases
    ADD CONSTRAINT purchases_pkey PRIMARY KEY (id);


--
-- TOC entry 72 (OID 2073550)
-- Name: seller_info_pkey; Type: CONSTRAINT; Schema: public; Owner: aswas
--

ALTER TABLE ONLY seller_info
    ADD CONSTRAINT seller_info_pkey PRIMARY KEY (buzz_user_id);


--
-- TOC entry 73 (OID 2073605)
-- Name: buzz_user_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: aswas
--

ALTER TABLE ONLY buzz_user_profile
    ADD CONSTRAINT buzz_user_profile_pkey PRIMARY KEY (buzz_user_id);


--
-- TOC entry 75 (OID 2074715)
-- Name: recommendation_pkey; Type: CONSTRAINT; Schema: public; Owner: aswas
--

ALTER TABLE ONLY recommendation
    ADD CONSTRAINT recommendation_pkey PRIMARY KEY (reco_id);


--
-- TOC entry 77 (OID 2075156)
-- Name: paypal_pkey; Type: CONSTRAINT; Schema: public; Owner: aswas
--

ALTER TABLE ONLY paypal
    ADD CONSTRAINT paypal_pkey PRIMARY KEY (id);


--
-- TOC entry 78 (OID 2075174)
-- Name: paypal_trans_pkey; Type: CONSTRAINT; Schema: public; Owner: aswas
--

ALTER TABLE ONLY paypal_trans
    ADD CONSTRAINT paypal_trans_pkey PRIMARY KEY (id);


--
-- TOC entry 74 (OID 2075383)
-- Name: ebay_pk; Type: CONSTRAINT; Schema: public; Owner: aswas
--

ALTER TABLE ONLY ebay
    ADD CONSTRAINT ebay_pk PRIMARY KEY (buzz_user_id);


--
-- TOC entry 80 (OID 2075417)
-- Name: commission_schedule_pkey; Type: CONSTRAINT; Schema: public; Owner: aswas
--

ALTER TABLE ONLY commission_schedule
    ADD CONSTRAINT commission_schedule_pkey PRIMARY KEY (id);


--
-- TOC entry 108 (OID 2073595)
-- Name: referral_foreign_key; Type: FK CONSTRAINT; Schema: public; Owner: aswas
--

ALTER TABLE ONLY purchases
    ADD CONSTRAINT referral_foreign_key FOREIGN KEY (referral_id) REFERENCES referral(id) MATCH FULL;


--
-- TOC entry 35 (OID 2073406)
-- Name: buzz_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aswas
--

SELECT pg_catalog.setval('buzz_user_id_seq', 18, true);


--
-- TOC entry 36 (OID 2073480)
-- Name: seller_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aswas
--

SELECT pg_catalog.setval('seller_category_id_seq', 1, true);


--
-- TOC entry 37 (OID 2073497)
-- Name: referral_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aswas
--

SELECT pg_catalog.setval('referral_id_seq', 12, true);


--
-- TOC entry 38 (OID 2073516)
-- Name: purchases_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aswas
--

SELECT pg_catalog.setval('purchases_id_seq', 1, false);


--
-- TOC entry 39 (OID 2073753)
-- Name: invites_invite_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aswas
--

SELECT pg_catalog.setval('invites_invite_id_seq', 7, true);


--
-- TOC entry 6 (OID 2074048)
-- Name: system_messages_seq; Type: SEQUENCE SET; Schema: public; Owner: aswas
--

SELECT pg_catalog.setval('system_messages_seq', 1, false);


--
-- TOC entry 8 (OID 2074050)
-- Name: audit_trail_seq; Type: SEQUENCE SET; Schema: public; Owner: aswas
--

SELECT pg_catalog.setval('audit_trail_seq', 1, false);


--
-- TOC entry 40 (OID 2074707)
-- Name: recommendation_reco_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aswas
--

SELECT pg_catalog.setval('recommendation_reco_id_seq', 4, true);


--
-- TOC entry 41 (OID 2075148)
-- Name: paypal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aswas
--

SELECT pg_catalog.setval('paypal_id_seq', 1, false);


--
-- TOC entry 42 (OID 2075166)
-- Name: paypal_trans_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aswas
--

SELECT pg_catalog.setval('paypal_trans_id_seq', 1, false);


--
-- TOC entry 43 (OID 2075407)
-- Name: commission_schedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: aswas
--

SELECT pg_catalog.setval('commission_schedule_id_seq', 1, false);


SET SESSION AUTHORIZATION 'postgres';

--
-- TOC entry 3 (OID 2200)
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'Standard public schema';


