CREATE OR REPLACE VIEW commissions_due_to_me_paid AS
SELECT
	p.comm_id AS comm_id,
	p.amount AS amount,
	p.paid_date AS paid_date,
	p.purchase_id AS purchase_id,
	b1.username AS seller_name,
	b2.username AS payee_name,
	p.seller_id AS seller_id,
	p.payee_id AS payee_id,
	p.referral_id AS referral_id,
	now() - p.paid_date AS numDaysOld
FROM 
	paid_comms p,
	buzz_user b1,
	buzz_user b2
WHERE
	    p.seller_id = b1.id 
	AND	p.payee_id = b2.id 
	AND p.paid_date < (current_date + 180) 
;

create or replace view commissions_due_to_me_unpaid as
	SELECT
		o.id as id,
                o.amount as amount,
                o.payable as payable,
                o.purchase_id as purchase_id,
                b1.username as buzz_name,
                o.buzz_user_id as payee_id,
                o.referral_id as referral_id	,
		b2.username as payee_name,
		now() - r.date_added as numDaysOld
	FROM 
		open_comm o,
		buzz_user b1,
		referral r,
		buzz_user b2
	WHERE
		o.buzz_user_id = b1.id
		and r.id = o.referral_id
		and r.buzz_user_id = b2.id

;

create or replace view admin_hive_list as
	SELECT
		b1.username as buzz_user_name,
		b2.username as victim_name,
		b1.username as hive_owner,
		b2.username as hive_member,
		h.date_added as date_added
	FROM 
		hive h,
		buzz_user b1,
		buzz_user b2
	WHERE
		h.buzz_user_id = b1.id and
		h.member_id = b2.id		
;

create or replace view admin_honeycomb_list as
	SELECT
		b1.username as buzz_user_name,
		b2.username as victim_name,
		b1.username as honeycomb_owner,
		b2.username as honeycomb_member,
		h.date_added as date_added
	FROM 
		honeycomb h,
		buzz_user b1,
		buzz_user b2
	WHERE
		h.buzz_user_id = b1.id and
		h.member_id = b2.id		
;

create or replace view admin_referral_list as
	SELECT
		h.id as id,
		b1.username as buzz_user_name,
		b2.username as victim_name,
		b3.username as seller_name,
		h.date_added as date_added,
		h.comm_schedule as commission_schedule_id,
		h.rebate_id as rebate_id
	FROM 
		referral h,
		buzz_user b1,
		buzz_user b2,
		buzz_user b3
	WHERE
		h.buzz_user_id = b1.id and
		h.refer_user_id = b2.id and
		h.seller_id = b3.id	
;

create or replace view admin_buzz_user_list as
	SELECT
                b1.id as id,
		b1.username as buzz_user_name,
		b1.email as email,
		't' as active_user
	FROM 
		buzz_user b1
	UNION
	SELECT
                b1.id as id,
		b1.username as buzz_user_name,
		b1.email as email,
		'f' as active_user
	FROM 
		suspended_user b1
;

create or replace view admin_user_messages_list as
	SELECT
		h.id as id,
		h.message as message,
		b1.username as buzz_user_name,
		h.date_added as date_added
	FROM 
		user_profile_mesgs h,
		buzz_user b1
	WHERE
		h.buzz_user_id = b1.id	
;


create or replace view admin_recommendation_list as
	SELECT
		h.reco_id as id,
		b1.username as buzz_user_name,
		b2.username as victim_name
	FROM 
		recommendation h,
		buzz_user b1,
		buzz_user b2
	WHERE
		h.buzz_user_id = b1.id and
		h.seller_id = b2.id		
;

create or replace view admin_blacklist_list as
	SELECT
		b1.username as buzz_user_name,
		b2.username as victim_name
	FROM 
		blocked_emails h,
		buzz_user b1,
		buzz_user b2
	WHERE
		h.to_id = b1.id and
		h.from_id = b2.id		
;



