-- Insert initial data
INSERT INTO test.pos_test_stage_setting(name, description)
VALUES 
('in_account', 'In Account'),
('parked', 'Parked'),
('layby', 'Layby');


INSERT INTO test.price_group_setting(name, currency_type, currency_list)
VALUES 
('vip_customer', 'custom_currencies', ARRAY['BDT', 'USD']);

INSERT INTO test.barcodes_setting(name, description)
VALUES 
('sku', 'Only Allow SKUs'),
('price', 'Allow Barcode with Embedded Price'),
('weight', 'Allow Barcode with Embedded Weight');


INSERT INTO test.test_order_types_setting(name, description)
VALUES 
('test', 'test'),
('credit_return', 'Credit Return');

INSERT INTO test.test_order_status_setting(name, description)
VALUES 
('estimate', 'Estimate'),
('issued', 'Issued'),
('in_progress', 'In Progress'),
('fulfilled', 'Fulfilled'),
('closed_short', 'Closed Short'),
('void', 'Void'),
('expired', 'Expired');



INSERT INTO test.test_order(test_order_number, customer_id, test_person_id, payment_term_id, sub_total, total_after_discount, tax_total, total_bill)
VALUES 
('56ef585e-8024-4417-b031-da878f6b8e27', '56ef585e-8024-4417-b031-da878f6b8e27', '56ef585e-8024-4417-b031-da878f6b8e27', 
'56ef585e-8024-4417-b031-da878f6b8e27', 100, 100, 0, 100);

-- INSERT INTO test_order_items(product_name, sku, uom, price_per_uom, quantity, price, tax, total, test_order_id)
-- VALUES 
-- ('Mens Shirt', 'MS000124', '5 Piece', 100, 5, 500, 0, 500, '7c41c5f4-2735-490d-a087-2a05d37aee5c');

-- INSERT INTO test_account(invoice_number, customer_id, payment_term_id, paid_amount, paid_date, payment_method_id, test_order_id)
-- VALUES 
-- ('INV0002', '56ef585e-8024-4417-b031-da878f6b8e27', '56ef585e-8024-4417-b031-da878f6b8e27', 1000, current_timestamp AT TIME ZONE 'UTC', '56ef585e-8024-4417-b031-da878f6b8e27', '7c41c5f4-2735-490d-a087-2a05d37aee5c');

INSERT INTO test.promotional_offer(name, start_at, end_at, customer_type, inventory_type, product_type, change_test_price, adjustment_types, rounding_type)
VALUES 
('Flash Sell Dec 21', '2021-12-01 00:00:00+06', '2021-12-01 00:00:00+06', 'all_customers', 'test', 'all_products', 'percentage', 'decrease_by', 'no_rounding');


-- UPDATE test_order_items
-- SET quantity = 2
-- WHERE id = 2;


-- UPDATE test_order_items
-- SET quantity = 2
-- WHERE id = 2;

-- UPDATE test_account
-- SET invoice_payment_status = 'Paid'
-- WHERE id = 1;

