create table customer_master ( 
    cust_id number generated always as identity primary key, 
    cust_name varchar2(150) not null, 
    dob date, 
    phone_no varchar2(15), 
    email_id varchar2(150), 
    address_line1 varchar2(200), 
    address_line2 varchar2(200), 
    city_name varchar2(100), 
    state_name varchar2(100), 
    pincode varchar2(10), 
    id_proof_type varchar2(50), 
    id_proof_number varchar2(50), 
    registered_on timestamp default systimestamp, 
    updated_on timestamp default systimestamp 
); 
 
create table term_deposits ( 
    td_id number generated always as identity primary key, 
    cust_id number not null, 
    td_code varchar2(50) unique not null, 
    td_amount number(15,2) not null check (td_amount > 0), 
    interest_percent number(5,2) not null check (interest_percent >= 0), 
    start_date date not null, 
    tenure_days number not null check (tenure_days > 0), 
    maturity_date date generated always as (start_date + tenure_days) virtual, 
    payout_frequency varchar2(20) default 'annual',  
    td_status varchar2(20) default 'active' check (td_status in ('active','matured','closed')) not null, 
    nominee_fullname varchar2(150), 
    nominee_relation varchar2(50), 
    opened_by_staff number, 
    closed_on date, 
    created_on timestamp default systimestamp, 
    foreign key (cust_id) references customer_master(cust_id) 
); 
 
create table withdrawal_records ( 
    w_id number generated always as identity primary key, 
    td_id number not null, 
    withdraw_ts timestamp default systimestamp, 
    withdraw_amt number(15,2) not null check (withdraw_amt > 0), 
    early_withdraw_flag number(1) default 0 not null,  
    penalty_charged number(15,2) default 0 not null, 
    tds_amount number(15,2) default 0, 
    remaining_balance number(15,2), 
    mode_of_payment varchar2(20),  
    transaction_id varchar2(100), 
    remarks nvarchar2(1000), 
    processed_by varchar2(100), 
    foreign key (td_id) references term_deposits(td_id) 
); 
 
create table deposit_status_audit ( 
    audit_id number generated always as identity primary key, 
    td_id number not null, 
    old_status varchar2(20), 
    new_status varchar2(20), 
    change_ts timestamp default systimestamp, 
    changed_by varchar2(100), 
    change_reason varchar2(200), 
    notes nvarchar2(1000), 
    foreign key (td_id) references term_deposits(td_id) 
); 
 
create table bank_config ( 
    config_key varchar2(100) primary key, 
    config_value number(18,6), 
    config_desc nvarchar2(500), 
    category_type varchar2(50), 
    last_modified timestamp default systimestamp 
); 
 
create table branch_directory ( 
    branch_id number generated always as identity primary key, 
    branch_code varchar2(20) unique not null, 
    branch_name varchar2(150) not null, 
    branch_city varchar2(100), 
    branch_state varchar2(100), 
    contact_no varchar2(15), 
    manager_incharge varchar2(100), 
    opened_date date 
); 
 
create table staff_directory ( 
    staff_id number generated always as identity primary key, 
    staff_name varchar2(150), 
    role_title varchar2(50), 
    branch_id number, 
    phone_no varchar2(15), 
    email_id varchar2(150), 
    hire_date date, 
    foreign key (branch_id) references branch_directory(branch_id) 
); 



-- 1. Customers
INSERT INTO customer_master (cust_name, dob, phone_no, email_id, address_line1, city_name, state_name, pincode, id_proof_type, id_proof_number) VALUES
('Arjun Mehta', DATE '1985-04-15', '9876543210', 'arjun.mehta@example.com', '12 MG Road', 'Bangalore', 'Karnataka', '560001', 'Aadhaar', '1234-5678-9012'),
('Priya Sharma', DATE '1990-07-20', '9765432109', 'priya.sharma@example.com', '45 Park Street', 'Mumbai', 'Maharashtra', '400001', 'PAN', 'ABCDE1234F'),
('Rahul Nair', DATE '1978-11-05', '9654321098', 'rahul.nair@example.com', '22 Residency Road', 'Chennai', 'Tamil Nadu', '600002', 'Passport', 'N1234567'),
('Sneha Gupta', DATE '1995-02-28', '9543210987', 'sneha.gupta@example.com', '88 Lake View', 'Delhi', 'Delhi', '110001', 'Aadhaar', '2345-6789-0123'),
('Vikram Reddy', DATE '1982-09-10', '9432109876', 'vikram.reddy@example.com', '77 Hill Top', 'Hyderabad', 'Telangana', '500001', 'PAN', 'XYZAB9876C');

-- 2. Branch Directory
INSERT INTO branch_directory (branch_code, branch_name, branch_city, branch_state, contact_no, manager_incharge, opened_date) VALUES
('BR001', 'MG Road Branch', 'Bangalore', 'Karnataka', '0801234567', 'Rajesh Kumar', DATE '2010-06-10'),
('BR002', 'Churchgate Branch', 'Mumbai', 'Maharashtra', '0222345678', 'Anita Desai', DATE '2012-08-15'),
('BR003', 'Anna Nagar Branch', 'Chennai', 'Tamil Nadu', '0443456789', 'Manoj Iyer', DATE '2015-01-20'),
('BR004', 'Connaught Place Branch', 'Delhi', 'Delhi', '0114567890', 'Rohit Sinha', DATE '2018-03-05'),
('BR005', 'Banjara Hills Branch', 'Hyderabad', 'Telangana', '0405678901', 'Deepa Reddy', DATE '2020-09-12');

-- 3. Staff Directory
INSERT INTO staff_directory (staff_name, role_title, branch_id, phone_no, email_id, hire_date) VALUES
('Neha Singh', 'Clerk', 1, '9988776655', 'neha.singh@bank.com', DATE '2020-03-01'),
('Amit Verma', 'Manager', 2, '8877665544', 'amit.verma@bank.com', DATE '2018-05-12'),
('Kavita Rao', 'Cashier', 3, '7766554433', 'kavita.rao@bank.com', DATE '2019-07-25'),
('Suresh Patel', 'Officer', 4, '6655443322', 'suresh.patel@bank.com', DATE '2021-01-10'),
('Pooja Nair', 'Clerk', 5, '5544332211', 'pooja.nair@bank.com', DATE '2022-06-15');

-- 4. Term Deposits
INSERT INTO term_deposits (cust_id, td_code, td_amount, interest_percent, start_date, tenure_days, payout_frequency, nominee_fullname, nominee_relation, opened_by_staff) VALUES
(1, 'TD2025001', 100000, 6.5, DATE '2025-01-01', 365, 'ANNUAL', 'Priya Mehta', 'Spouse', 1),
(2, 'TD2025002', 50000, 6.0, DATE '2025-02-15', 730, 'QUARTERLY', 'Rohit Sharma', 'Brother', 2),
(3, 'TD2025003', 75000, 5.5, DATE '2025-03-10', 365, 'ANNUAL', 'Anjali Nair', 'Wife', 3),
(4, 'TD2025004', 120000, 7.0, DATE '2025-04-05', 1095, 'MONTHLY', 'Rakesh Gupta', 'Father', 4),
(5, 'TD2025005', 60000, 6.2, DATE '2025-05-20', 365, 'ANNUAL', 'Meena Reddy', 'Mother', 5);

-- 5. Withdrawal Records
INSERT INTO withdrawal_records (td_id, withdraw_amt, mode_of_payment, transaction_id, remarks, processed_by) VALUES
(1, 20000, 'Bank Transfer', 'TXN10001', 'Premature withdrawal for medical expenses', 'Neha Singh'),
(2, 10000, 'Cash', 'TXN10002', 'Customer requested partial cash withdrawal', 'Amit Verma'),
(3, 15000, 'Cheque', 'TXN10003', 'Education fees payment', 'Kavita Rao'),
(4, 5000, 'Bank Transfer', 'TXN10004', 'Partial withdrawal for travel expenses', 'Suresh Patel'),
(5, 10000, 'Cash', 'TXN10005', 'Emergency withdrawal', 'Pooja Nair');

-- 6. Deposit Status Audit
INSERT INTO deposit_status_audit (td_id, old_status, new_status, changed_by, change_reason, notes) VALUES
(1, 'ACTIVE', 'CLOSED', 'Neha Singh', 'Full withdrawal made', 'Deposit closed successfully'),
(2, 'ACTIVE', 'MATURED', 'Amit Verma', 'Deposit reached maturity', 'Auto maturity update'),
(3, 'ACTIVE', 'ACTIVE', 'Kavita Rao', 'Interest payout credited', 'No status change'),
(4, 'ACTIVE', 'CLOSED', 'Suresh Patel', 'Premature closure by customer', 'Penalty applied'),
(5, 'ACTIVE', 'ACTIVE', 'Pooja Nair', 'Partial withdrawal made', 'Balance remains');

-- 7. Bank Config
INSERT INTO bank_config (config_key, config_value, config_desc, category_type) VALUES
('EarlyWithdrawPenaltyPercent', 2.5, 'Penalty applied for premature withdrawals', 'Penalty Policy'),
('AnnualTDSPercent', 10.0, 'Tax deducted at source on interest earned', 'Tax Policy'),
('DefaultInterestRate', 6.0, 'Standard FD interest rate for 1 year', 'Interest Policy'),
('SeniorCitizenExtraRate', 0.5, 'Additional interest rate benefit for senior citizens', 'Interest Policy'),
('MaxFDLimitPerCustomer', 1000000, 'Maximum FD amount allowed per customer', 'Deposit Policy');

--sp_open_term_deposit

create procedure sp_open_term_deposit (
    p_cust_id           in number,
    p_td_code           in varchar2,
    p_td_amount         in number,
    p_interest_pct      in number,
    p_start_date        in date,
    p_tenure_days       in number,
    p_nominee_name      in varchar2,
    p_nominee_relation  in varchar2,
    p_opened_by         in number
) as
    v_exists number;
begin
    select count(*) into v_exists from customer_master where cust_id = p_cust_id;
    if v_exists = 0 then
        raise_application_error(-20001, 'customer id does not exist.');
    end if;
    if p_td_amount <= 0 then
        raise_application_error(-20002, 'deposit amount must be greater than 0.');
    end if;
    if p_tenure_days <= 0 then
        raise_application_error(-20003, 'tenure days must be greater than 0.');
    end if;

    insert into term_deposits (
        cust_id, td_code, td_amount, interest_percent, start_date, tenure_days,
        nominee_fullname, nominee_relation, opened_by_staff, td_status, created_on
    )
    values (
        p_cust_id, p_td_code, p_td_amount, p_interest_pct, p_start_date, p_tenure_days,
        p_nominee_name, p_nominee_relation, p_opened_by, 'active', systimestamp
    );
    dbms_output.put_line('term deposit opened successfully for customer id ' || p_cust_id);
end;
/


-- sp_withdraw_from_deposit

create procedure sp_withdraw_from_deposit (
    p_td_id        in number,
    p_withdraw_amt in number,
    p_payment_mode in varchar2,
    p_txn_id       in varchar2,
    p_processed_by in varchar2
) as
    v_status          varchar2(20);
    v_total_withdrawn number(15,2);
    v_balance         number(15,2);
    v_penalty_percent number(10,2);
    v_penalty         number(15,2);
    v_maturity_date   date;
    v_early_flag      number(1);
begin
    begin
        select td_status, maturity_date into v_status, v_maturity_date
        from term_deposits where td_id = p_td_id;
    exception
        when no_data_found then
            raise_application_error(-20004, 'deposit account does not exist.');
    end;
    if v_status <> 'active' then
        raise_application_error(-20005, 'withdrawal not allowed: deposit is not active.');
    end if;
    if p_withdraw_amt <= 0 then
        raise_application_error(-20006, 'withdrawal amount must be greater than 0.');
    end if;
    select td_amount - nvl(sum(w.withdraw_amt),0)
    into v_balance
    from term_deposits t
    left join withdrawal_records w on t.td_id = w.td_id
    where t.td_id = p_td_id
    group by td_amount;
    if p_withdraw_amt > v_balance then
        raise_application_error(-20007, 'withdrawal exceeds available balance.');
    end if;
    if sysdate < v_maturity_date then
        v_early_flag := 1;
        select config_value into v_penalty_percent
        from bank_config where config_key = 'earlywithdrawpenaltypercent';
        v_penalty := round(p_withdraw_amt * (v_penalty_percent / 100), 2);
    else
        v_early_flag := 0;
        v_penalty := 0;
    end if;
    insert into withdrawal_records (
        td_id, withdraw_amt, early_withdraw_flag, penalty_charged,
        mode_of_payment, transaction_id, processed_by, remaining_balance
    )
    values (
        p_td_id, p_withdraw_amt, v_early_flag, v_penalty,
        p_payment_mode, p_txn_id, p_processed_by,
        v_balance - p_withdraw_amt - v_penalty
    );
    dbms_output.put_line('withdrawal successful. penalty applied: ' || v_penalty);
end;
/


--  sp_close_deposit

create procedure sp_close_deposit (
    p_td_id     in number,
    p_closed_by in varchar2,
    p_reason    in varchar2
) as
    v_status varchar2(20);
begin
    begin
        select td_status into v_status from term_deposits where td_id = p_td_id;
    exception
        when no_data_found then
            raise_application_error(-20008, 'deposit id does not exist.');
    end;
    if v_status <> 'active' then
        raise_application_error(-20009, 'only active deposits can be closed.');
    end if;
    update term_deposits
    set td_status = 'closed', closed_on = sysdate
    where td_id = p_td_id;
    insert into deposit_status_audit (
        td_id, old_status, new_status, changed_by, change_reason, notes
    )
    values (
        p_td_id, v_status, 'closed', p_closed_by, p_reason, 'closed by procedure'
    );
    dbms_output.put_line('deposit id ' || p_td_id || ' closed successfully.');
end;
/


--Procedure: sp_update_customer

create procedure sp_update_customer (
    p_cust_id   in number,
    p_phone     in varchar2,
    p_email     in varchar2,
    p_address1  in varchar2,
    p_address2  in varchar2,
    p_city      in varchar2,
    p_state     in varchar2,
    p_pincode   in varchar2
) as
    v_exists number;
begin
    select count(*) into v_exists from customer_master where cust_id = p_cust_id;
    if v_exists = 0 then
        raise_application_error(-20010, 'customer id does not exist.');
    end if;
    if length(p_phone) < 10 then
        raise_application_error(-20011, 'invalid phone number.');
    end if;
    if instr(p_email, '@') = 0 then
        raise_application_error(-20012, 'invalid email format.');
    end if;
    update customer_master
    set phone_no = p_phone,
        email_id = p_email,
        address_line1 = p_address1,
        address_line2 = p_address2,
        city_name = p_city,
        state_name = p_state,
        pincode = p_pincode,
        updated_on = systimestamp
    where cust_id = p_cust_id;
    dbms_output.put_line('customer details updated for id ' || p_cust_id);
end;
/

INSERT INTO customer_master (
    cust_name, 
    dob, 
    phone_no, 
    email_id, 
    address_line1, 
    address_line2, 
    city_name, 
    state_name, 
    pincode, 
    id_proof_type, 
    id_proof_number 
    
) 
VALUES (
    'Deepak Sharma', 
    DATE '1985-06-15',            
    '9988776655', 
    'deepak.sharma@example.in', 
    'Flat 101, Galaxy Apartments', 
    'Near City Center Mall', 
    'Mumbai', 
    'Maharashtra', 
    '400001', 
    'Aadhaar', 
    '123456789012'
);




BEGIN
    sp_open_term_deposit (
        p_cust_id           => 1,
        p_td_code           => 'FD_1Y_SEP55',       
        p_td_amount         => 75000.00,            
        p_interest_pct      => 6.50,                
        p_start_date        => DATE '2025-09-25',   
        p_tenure_days       => 365,
        p_nominee_name      => 'Priya Sharma',
        p_nominee_relation  => 'Wife',
        p_opened_by         => 707                  
    );
END;
/
SELECT
    td_id,
    cust_id,
    td_code,
    td_amount,
    interest_percent,
    start_date,
    tenure_days,
    maturity_date,
    td_status
FROM
    term_deposits
WHERE
    td_code = 'FD_1Y_SEP55'; 


BEGIN
    sp_update_customer (
        p_cust_id   => 1,                           
        p_phone     => '9988776600',               
        p_email     => 'deepak.s.new@example.in',   
        p_address1  => ' blk B, Sector 15',
        p_address2  => 'Near Metro Station',
        p_city      => 'Gurugram',
        p_state     => 'Haryana',
        p_pincode   => '122001'
    );
END;
/
SELECT
    cust_id,
    phone_no,
    email_id,
    address_line1,
    city_name,
    state_name,
    pincode,
    updated_on
FROM
    customer_master
WHERE
    cust_id = 1;


BEGIN
    sp_withdraw_from_deposit (
        p_td_id        => 1,                       
        p_withdraw_amt => 10000.00,                
        p_payment_mode => 'NEFT',
        p_txn_id       => 'NEFT_TDW_0025A',       
        p_processed_by => 'STAFF_MOHAN'
    );
END;

SELECT
    td_id,
    withdraw_amt,
    penalty_charged,
    remaining_balance,
    mode_of_payment,
    transaction_id
FROM
    withdrawal_records
WHERE
    transaction_id = 'NEFT_TDW_0025A';
/

BEGIN
    sp_close_deposit (
        p_td_id     => 1,                          
        p_closed_by => 'STAFF_KOMAL',
        p_reason    => 'Premature closure requested by customer.'
    );
END;
/

SELECT
    td_id,
    td_status,
    td_amount,
    closed_on
FROM
    term_deposits
WHERE
    td_id = 1;

    --triggers for auto-update stock 
drop trigger trg_withdrawal_penalty

create trigger trg_withdrawal_penalty
after insert on withdrawal_records
for each row
declare
    v_status            varchar2(20);
    v_td_amount         number(15,2);
    v_interest_percent  number(5,2);
    v_start_date        date;
    v_maturity_date     date;
    v_days_elapsed      number;
    v_accrued_interest  number(15,2);
    v_already_withdrawn number(15,2);
    v_penalty_percent   number(18,6);
    v_penalty_amount    number(15,2);
    v_remaining         number(15,2);
begin
    
    select td_status, td_amount, interest_percent, start_date, maturity_date
    into v_status, v_td_amount, v_interest_percent, v_start_date, v_maturity_date
    from term_deposits
    where td_id = :new.td_id;
    if v_status <> 'active' then
        raise_application_error(-20001, 'withdrawal not allowed: deposit is not active.');
    end if;
    v_days_elapsed := trunc(sysdate) - v_start_date;
    v_accrued_interest := round((v_td_amount * v_interest_percent / 100) * (v_days_elapsed / 365), 2);
    select nvl(sum(withdraw_amt + penalty_charged), 0)
    into v_already_withdrawn
    from withdrawal_records
    where td_id = :new.td_id;

   
    if trunc(sysdate) < v_maturity_date then
        select nvl(config_value, 0)
        into v_penalty_percent
        from bank_config
        where config_key = 'earlywithdrawpenaltypercent';

        v_penalty_amount := round(:new.withdraw_amt * (v_penalty_percent / 100), 2);

        update withdrawal_records
        set early_withdraw_flag = 1,
            penalty_charged = v_penalty_amount
        where w_id = :new.w_id;
    else
        v_penalty_amount := 0;
    end if;

    v_remaining := v_td_amount + v_accrued_interest - (v_already_withdrawn);
    update withdrawal_records
    set remaining_balance = v_remaining
    where w_id = :new.w_id;

    if v_remaining <= 0 then
        update term_deposits
        set td_status = 'closed',
            closed_on = sysdate
        where td_id = :new.td_id;

        insert into deposit_status_audit (td_id, old_status, new_status, changed_by, change_reason)
        values (:new.td_id, v_status, 'closed', 'trigger-system', 'full withdrawal');
    end if;
end;
/

--trigger for deposit status

create trigger trg_deposit_status_audit
after update of td_status on term_deposits
for each row
begin
 
    if :old.td_status <> :new.td_status then
        insert into deposit_status_audit (td_id,old_status,new_status,changed_by,change_reason,notes) 
        values (:new.td_id,:old.td_status,:new.td_status,user,'status changed automatically or by staff','trigger logged the status change');
    end if;
end;
/

--trigger Auto-Mature Deposit Accounts
create or replace trigger trg_auto_mature_td
before update on term_deposits
for each row
begin
    if :new.td_status = 'active'
       and :new.maturity_date <= trunc(sysdate) then
        :new.td_status := 'matured';
    end if;
end;
/



--trigger_customer_update_audit

create trigger trg_customer_update_audit
after update on customer_master
for each row
begin
    
    update customer_master
    set updated_on = systimestamp
    where cust_id = :new.cust_id;

  
    insert into deposit_status_audit (td_id,old_status,new_status,changed_by,change_reason,notes)
    select td_id,'CUSTOMER_UPDATE','CUSTOMER_UPDATE',user,'Customer information updated','Trigger logged the customer update'
    from term_deposits
    where cust_id = :new.cust_id;
end;
/

--trigger for auto update when customer changes inform
create trigger trg_customer_updated_on
before update on customer_master
for each row
begin
/
    :new.updated_on := systimestamp;
end;



-- FDs Maturing in Next 30 Days
create view vw_fd_maturing_soon as
select 
    td.td_id,
    cm.cust_name,
    td.td_code,
    td.td_amount,
    td.start_date,
    td.maturity_date,
    td.td_status
from term_deposits td
join customer_master cm on td.cust_id = cm.cust_id
where td.maturity_date between sysdate and (sysdate + 30)
  and td.td_status = 'active';

--  Active Deposits with Balance
create view vw_active_deposits as
select 
    td.td_id,
    cm.cust_name,
    td.td_code,
    td.td_amount,
    td.interest_percent,
    td.maturity_date,
    td.td_status
from term_deposits td
join customer_master cm on td.cust_id = cm.cust_id
where td.td_status = 'active';

-- Withdrawals with Penalties
create view vw_withdrawals_penalty as
select 
    wr.w_id,
    td.td_code,
    cm.cust_name,
    wr.withdraw_amt,
    wr.withdraw_ts,
    wr.early_withdraw_flag,
    wr.penalty_charged,
    wr.remarks,
    wr.processed_by
from withdrawal_records wr
join term_deposits td on wr.td_id = td.td_id
join customer_master cm on td.cust_id = cm.cust_id
where wr.early_withdraw_flag = 1;

-- Branch-Wise Deposit
create view vw_branch_deposit_summary as
select 
    bd.branch_name,
    count(td.td_id) as total_deposits,
    sum(td.td_amount) as total_amount
from term_deposits td
join staff_directory sd on td.opened_by_staff = sd.staff_id
join branch_directory bd on sd.branch_id = bd.branch_id
group by bd.branch_name;


-- Customer-Wise Deposit 
create view vw_customer_deposit_summary as
select 
    cm.cust_id,
    cm.cust_name,
    count(td.td_id) as total_fd_count,
    sum(td.td_amount) as total_fd_amount
from term_deposits td
join customer_master cm on td.cust_id = cm.cust_id
group by cm.cust_id, cm.cust_name;