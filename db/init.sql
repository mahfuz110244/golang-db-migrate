-- Database: test

-- DROP DATABASE IF EXISTS test;

CREATE DATABASE test
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

GRANT ALL ON DATABASE test TO postgres;

GRANT TEMPORARY, CONNECT ON DATABASE test TO PUBLIC;

GRANT ALL ON DATABASE test TO mahfuz;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
-- Create Pos test Status Settings Table
-- CREATE TYPE pos_test_status_enum AS ENUM ('in_account', 'parked', 'layby');
CREATE TABLE IF NOT EXISTS pos_test_stage_setting (
	id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
	created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (current_timestamp AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (current_timestamp AT TIME ZONE 'UTC'),
	deleted_at TIMESTAMP WITHOUT TIME ZONE NULL DEFAULT NULL,
	created_by UUID,
	updated_by UUID,
	name VARCHAR (20) NOT NULL,
	description VARCHAR (255),
	is_is_active BOOLEAN NOT NULL DEFAULT TRUE,
	order_number smallint DEFAULT 0,
	UNIQUE(name)
);


-- Create Pos test Status Settings Table
CREATE TYPE currency_type_enum AS ENUM ('all_currencies', 'custom_currencies');
CREATE TABLE IF NOT EXISTS price_group_setting (
	id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
	created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (current_timestamp AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (current_timestamp AT TIME ZONE 'UTC'),
	deleted_at TIMESTAMP WITHOUT TIME ZONE NULL DEFAULT NULL,
	created_by UUID,
	updated_by UUID,
	name VARCHAR(50) NOT NULL,
	description VARCHAR (255) NULL,
	currency_type currency_type_enum,
	currency_list VARCHAR [],
	is_active BOOLEAN NOT NULL DEFAULT TRUE,
	UNIQUE(name)
);

-- Create Barcode Settings Table
-- CREATE TYPE barcodes_enum AS ENUM ('sku', 'price', 'weight');
-- ALTER TYPE barcodes_enum ADD VALUE 'sku_new';
-- DROP ATTRIBUTE [ IF EXISTS ] sku_new [ CASCADE | RESTRICT ]
-- ALTER COLUMN name TYPE barcodes_enum USING name::barcodes_enum;
CREATE TABLE IF NOT EXISTS barcodes_setting (
	id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
	created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (current_timestamp AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (current_timestamp AT TIME ZONE 'UTC'),
	deleted_at TIMESTAMP WITHOUT TIME ZONE NULL DEFAULT NULL,
	created_by UUID,
	updated_by UUID,
	name VARCHAR(20) NOT NULL,
	description VARCHAR (255),
	is_active BOOLEAN NOT NULL DEFAULT TRUE,
	order_no smallint DEFAULT 0,
	UNIQUE(name)
);

-- Create order type Table
-- CREATE TYPE sale_order_types_enum AS ENUM ('test', 'credit_return');
CREATE TABLE IF NOT EXISTS test_order_types_setting (
	id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
	created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (current_timestamp AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (current_timestamp AT TIME ZONE 'UTC'),
	deleted_at TIMESTAMP WITHOUT TIME ZONE NULL DEFAULT NULL,
	created_by UUID,
	updated_by UUID,
	name VARCHAR(20) NOT NULL,
	description VARCHAR (255),
	is_active BOOLEAN NOT NULL DEFAULT TRUE,
	order_no smallint DEFAULT 0,
	UNIQUE(name)
);

-- Create test order status setting Table
-- CREATE TYPE test_order_status_enum AS ENUM ('estimate', 'issued', 'in_progress', 'fulfilled', 'closed_short', 'void', 'expired');
CREATE TABLE IF NOT EXISTS test_order_status_setting (
	id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
	created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (current_timestamp AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (current_timestamp AT TIME ZONE 'UTC'),
	deleted_at TIMESTAMP WITHOUT TIME ZONE NULL DEFAULT NULL,
	created_by UUID,
	updated_by UUID,
	name VARCHAR(20) NOT NULL,
	description VARCHAR (255),
	is_active BOOLEAN NOT NULL DEFAULT TRUE,
	order_no smallint DEFAULT 0,
	UNIQUE(name)
);


-- Create test order Table
CREATE TYPE test_operation_type_enum AS ENUM ('test', 'test Return', 'Service');
CREATE TABLE IF NOT EXISTS test_order (
	id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
	created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (current_timestamp AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (current_timestamp AT TIME ZONE 'UTC'),
	deleted_at TIMESTAMP WITHOUT TIME ZONE NULL DEFAULT NULL,
	created_by UUID,
	updated_by UUID,
	location_group_id VARCHAR (36) NULL,
	test_operation_type test_operation_type_enum DEFAULT 'test',
	tax_group_id VARCHAR (36) NULL,
	test_order_number VARCHAR (36) NOT NULL,
	status VARCHAR (36) NOT NULL DEFAULT 'estimate',
	customer_id VARCHAR (36) NOT NULL,
	customer_purchase_order_id VARCHAR (36) NULL,
	test_person_id VARCHAR (36) NOT NULL,
	carrier_id VARCHAR (36) NULL,
	carrier_service_id VARCHAR (36) NULL,
	payment_term_id VARCHAR (36) NOT NULL,
	sub_total numeric(12,2) NOT NULL,
	discount numeric(3,2) DEFAULT 0,
	total_after_discount numeric(12,2) NOT NULL,
	tax_total numeric(12,2) DEFAULT 0,
	shipping_charge numeric(12,2) DEFAULT 0,
	total_bill numeric(12,2) NOT NULL,
	scheduled_at TIMESTAMP WITHOUT TIME ZONE NULL DEFAULT NULL,
	completed_at TIMESTAMP WITHOUT TIME ZONE NULL DEFAULT NULL,
	note TEXT NULL,
	UNIQUE(test_order_number)
);

CREATE INDEX test_order_created_at_idx
ON test_order(created_at DESC);

CREATE INDEX test_order_scheduled_at_idx
ON test_order(scheduled_at DESC);

CREATE INDEX test_order_completed_at_idx
ON test_order(completed_at DESC);

CREATE INDEX test_order_customer_id_idx
ON test_order(customer_id DESC);

CREATE INDEX test_order_customer_purchase_order_id_idx
ON test_order(customer_purchase_order_id DESC);

CREATE INDEX test_order_status_idx
ON test_order(status DESC);



-- Create test order items setting Table
CREATE TABLE IF NOT EXISTS test_order_items (
	id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
	created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (current_timestamp AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (current_timestamp AT TIME ZONE 'UTC'),
	deleted_at TIMESTAMP WITHOUT TIME ZONE NULL DEFAULT NULL,
	created_by UUID,
	updated_by UUID,
	product_name VARCHAR (255) NOT NULL,
	sku VARCHAR (36) NOT NULL,
	variant VARCHAR (36) NULL,
	size VARCHAR (50) NULL,
	uom VARCHAR (36) NOT NULL,
	quantity numeric(5,2) NOT NULL,
	price_per_uom numeric(12,2) NOT NULL,
	price numeric(12,2) NOT NULL,
	tax numeric(12,2) NULL,
	discount numeric(3,2) DEFAULT 0,
	total numeric(12,2) NOT NULL,
	test_order_id UUID  NOT NULL,
	CONSTRAINT fk_test_order FOREIGN KEY(test_order_id) REFERENCES test_order(id)
);

CREATE INDEX test_order_items_sku_idx
ON test_order_items(sku DESC);

CREATE INDEX test_order_items_test_order_id_idx
ON test_order_items(test_order_id DESC);




-- test account
-- create test accounts
CREATE TYPE invoice_payment_status_enum AS ENUM ('Paid', 'Unpaid');
CREATE TABLE IF NOT EXISTS test_account (
	id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
	created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (current_timestamp AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (current_timestamp AT TIME ZONE 'UTC'),
	deleted_at TIMESTAMP WITHOUT TIME ZONE NULL DEFAULT NULL,
	created_by UUID,
	updated_by UUID,
	location_group_id UUID NULL,
	invoice_number varchar(36) NOT NULL,
	customer_id UUID NOT NULL,
	invoice_payment_status invoice_payment_status_enum DEFAULT 'Unpaid',
	payment_term_id UUID NOT NULL,
	due_date TIMESTAMP WITHOUT TIME ZONE NULL DEFAULT NULL,
	due_amount numeric(12,2) DEFAULT 0,
	tax_amount numeric(12,2) DEFAULT 0,
	paid_amount numeric(12,2) DEFAULT 0,
	paid_date TIMESTAMP WITHOUT TIME ZONE NULL DEFAULT NULL,
	payment_method_id UUID NOT NULL,
	tax_account_id UUID,
	asset_account_id UUID,
	revenue_account_id UUID,
	test_order_id UUID  NOT NULL,
	CONSTRAINT fk_test_order FOREIGN KEY(test_order_id) REFERENCES test_order(id),
	UNIQUE(invoice_number)
);




CREATE INDEX test_account_created_at_idx
ON test_account(created_at DESC);

CREATE INDEX test_account_test_order_id_idx
ON test_account(test_order_id DESC);

CREATE INDEX test_account_customer_id_idx
ON test_account(customer_id DESC);

CREATE INDEX test_account_invoice_payment_status_idx
ON test_account(invoice_payment_status DESC);

CREATE INDEX test_account_revenue_account_id_idx
ON test_account(revenue_account_id DESC);

CREATE INDEX test_account_due_date_idx
ON test_account(due_date DESC);



-- Create POS test Billing Table
CREATE TABLE IF NOT EXISTS test_billing (
	id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
	created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (current_timestamp AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (current_timestamp AT TIME ZONE 'UTC'),
	deleted_at TIMESTAMP WITHOUT TIME ZONE NULL DEFAULT NULL,
	created_by UUID,
	updated_by UUID,
	location_group_id VARCHAR (36) NULL,
	invoice_number VARCHAR (36) NOT NULL,
	status VARCHAR (20) NOT NULL,
	enable_loyalty BOOLEAN NOT NULL DEFAULT FALSE,
	customer_id VARCHAR (36) NOT NULL,
	test_person_id VARCHAR (36) NOT NULL,
	payment_method_id VARCHAR (36) NOT NULL,
	sub_total numeric(12,2) NOT NULL,
	discount numeric(3,2) DEFAULT 0,
	total_after_discount numeric(12,2) NOT NULL,
	tax_total numeric(12,2) NOT NULL,
	shipping_charge numeric(12,2) DEFAULT 0,
	total_bill numeric(12,2) NOT NULL,
	note TEXT NULL,
	UNIQUE(invoice_number)
);
CREATE INDEX test_billing_created_at_idx
ON test_billing(created_at DESC);

CREATE INDEX test_billing_customer_id_idx
ON test_billing(customer_id DESC);

CREATE INDEX test_billing_status_idx
ON test_billing(status DESC);



-- Create Pose test Billing items setting Table
CREATE TABLE IF NOT EXISTS test_billing_items (
	id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
	created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (current_timestamp AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (current_timestamp AT TIME ZONE 'UTC'),
	deleted_at TIMESTAMP WITHOUT TIME ZONE NULL DEFAULT NULL,
	created_by UUID,
	updated_by UUID,
	product_name VARCHAR (255) NOT NULL,
	sku VARCHAR (36) NOT NULL,
	variant VARCHAR (36) NULL,
	size VARCHAR (50) NULL,
	uom VARCHAR (36) NOT NULL,
	quantity numeric(5,2) NOT NULL,
	price_per_uom numeric(12,2) NOT NULL,
	price numeric(12,2) NOT NULL,
	tax numeric(12,2) NULL,
	discount numeric(3,2) DEFAULT 0,
	total numeric(12,2) NOT NULL,
	test_billing_id UUID NOT NULL,
	CONSTRAINT fk_test_billing FOREIGN KEY(test_billing_id) REFERENCES test_billing(id)
);

CREATE INDEX test_billing_items_sku_idx
ON test_billing_items(sku DESC);

CREATE INDEX test_billing_items_test_billing_id_idx
ON test_billing_items(test_billing_id DESC);

CREATE TYPE customer_type_enum AS ENUM ('all_customers', 'custom_customers');
CREATE TYPE custom_customer_enum AS ENUM ('contact_type', 'contact_sub_group', 'customer_stage', 'individually');
CREATE TYPE change_test_price_enum AS ENUM ('percentage', 'fixed_amount', 'custom_price');
CREATE TYPE adjustment_types_enum AS ENUM ('increase_by', 'decrease_by');
CREATE TYPE rounding_type_enum AS ENUM ('no_rounding', '0.05', '.10', '.20', '.25', '50', '1.00');
CREATE TYPE product_type_enum AS ENUM ('all_products', 'custom_products');
CREATE TYPE custom_product_enum AS ENUM ('category', 'brand','individually');
-- Create Promotional Offer/ Projects setting Table
CREATE TABLE IF NOT EXISTS promotional_offer (
	id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
	created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (current_timestamp AT TIME ZONE 'UTC'),
    updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (current_timestamp AT TIME ZONE 'UTC'),
	deleted_at TIMESTAMP WITHOUT TIME ZONE NULL DEFAULT NULL,
	created_by UUID,
	updated_by UUID,
	name VARCHAR (100) NOT NULL,
	description VARCHAR (255) NULL,
	start_at TIMESTAMPTZ NOT NULL,
	end_at TIMESTAMPTZ NOT NULL,
	customer_type customer_type_enum,
	customer_custom_list custom_customer_enum [] NULL,
	customer_list VARCHAR (36) [] NULL,
	inventory_type VARCHAR (100) NOT NULL,
	
	product_type product_type_enum,
	product_custom_list custom_product_enum [] NULL,
	product_list VARCHAR (36) [] NULL,
	
	change_test_price change_test_price_enum,
	adjustment_types adjustment_types_enum,
	rounding_type rounding_type_enum
);
CREATE INDEX promotional_offer_start_at_idx
ON promotional_offer(start_at DESC);

CREATE INDEX promotional_offer_end_at_idx
ON promotional_offer(end_at DESC);


-- Step 1: Create trigger Function
CREATE OR REPLACE FUNCTION trigger_set_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW() AT TIME ZONE 'utc';
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Then create a trigger for each table that has the column updated_at
DO $$
DECLARE
    t text;
BEGIN
    FOR t IN
        SELECT table_name FROM information_schema.columns WHERE column_name = 'updated_at'
    LOOP
        EXECUTE format('CREATE TRIGGER trigger_set_update_timestamp
                    BEFORE UPDATE ON %I
                    FOR EACH ROW EXECUTE PROCEDURE trigger_set_update_timestamp()', t,t);
    END loop;
END;
$$ language 'plpgsql';



-- -- Step 2: Create the Table
-- CREATE TABLE base (
-- 	id SMALLSERIAL PRIMARY KEY,
-- 	created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
--   updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
-- 	deleted_at TIMESTAMP,
-- 	created_by VARCHAR (255),
-- 	updated_by VARCHAR (255)
-- );
-- 
-- INSERT INTO base(id)
-- VALUES(DEFAULT)



-- Step 3: Create the Trigger
-- CREATE TRIGGER set_timestamp
-- BEFORE UPDATE ON base
-- FOR EACH ROW
-- EXECUTE PROCEDURE trigger_set_update_timestamp();
-- 
-- UPDATE base
-- SET created_by = 'admin_uuid',
--     updated_by = 'admin_id'
-- WHERE id = 1;


INSERT INTO pos_test_stage_setting(name, description)
VALUES 
('in_account', 'In Account'),
('parked', 'Parked'),
('layby', 'Layby');


INSERT INTO price_group_setting(name, currency_type, currency_list)
VALUES 
('vip_customer', 'custom_currencies', ARRAY['BDT', 'USD']);

INSERT INTO barcodes_setting(name, description)
VALUES 
('sku', 'Only Allow SKUs'),
('price', 'Allow Barcode with Embedded Price'),
('weight', 'Allow Barcode with Embedded Weight');


INSERT INTO test_order_types_setting(name, description)
VALUES 
('test', 'test'),
('credit_return', 'Credit Return');

INSERT INTO test_order_status_setting(name, description)
VALUES 
('estimate', 'Estimate'),
('issued', 'Issued'),
('in_progress', 'In Progress'),
('fulfilled', 'Fulfilled'),
('closed_short', 'Closed Short'),
('void', 'Void'),
('expired', 'Expired');



INSERT INTO test_order(test_order_number, customer_id, test_person_id, payment_term_id, sub_total, total_after_discount, tax_total, total_bill)
VALUES 
('56ef585e-8024-4417-b031-da878f6b8e27', '56ef585e-8024-4417-b031-da878f6b8e27', '56ef585e-8024-4417-b031-da878f6b8e27', 
'56ef585e-8024-4417-b031-da878f6b8e27', 100, 100, 0, 100);

INSERT INTO test_order_items(product_name, sku, uom, price_per_uom, quantity, price, tax, total, test_order_id)
VALUES 
('Mens Shirt', 'MS000124', '5 Piece', 100, 5, 500, 0, 500, '7c41c5f4-2735-490d-a087-2a05d37aee5c');

INSERT INTO test_account(invoice_number, customer_id, payment_term_id, paid_amount, paid_date, payment_method_id, test_order_id)
VALUES 
('INV0002', '56ef585e-8024-4417-b031-da878f6b8e27', '56ef585e-8024-4417-b031-da878f6b8e27', 1000, current_timestamp AT TIME ZONE 'UTC', '56ef585e-8024-4417-b031-da878f6b8e27', '7c41c5f4-2735-490d-a087-2a05d37aee5c');

INSERT INTO promotional_offer(name, start_at, end_at, customer_type, inventory_type, product_type, change_test_price, adjustment_types, rounding_type)
VALUES 
('Flash Sell Dec 21', '2021-12-01 00:00:00+06', '2021-12-01 00:00:00+06', 'all_customers', 'test', 'all_products', 'percentage', 'decrease_by', 'no_rounding');


UPDATE test_order_items
SET quantity = 2
WHERE id = 2;


UPDATE test_order_items
SET quantity = 2
WHERE id = 2;

UPDATE test_account
SET invoice_payment_status = 'Paid'
WHERE id = 1;

