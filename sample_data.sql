CREATE TABLE students (
    student_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name   VARCHAR(50)  NOT NULL,
    last_name    VARCHAR(50)  NOT NULL,
    email        VARCHAR(100) UNIQUE,
    class_level  VARCHAR(20)  NOT NULL,
    enrolled_on  DATE         NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE fee_types (
    fee_type_id     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name            VARCHAR(50)   NOT NULL UNIQUE,
    default_amount  NUMERIC(10,2) NOT NULL CHECK (default_amount >= 0)
);

CREATE TABLE invoices (
    invoice_id   INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id   INT           NOT NULL REFERENCES students(student_id),
    fee_type_id  INT           NOT NULL REFERENCES fee_types(fee_type_id),
    amount       NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    issued_on    DATE          NOT NULL DEFAULT CURRENT_DATE,
    due_date     DATE          NOT NULL,
    CHECK (due_date >= issued_on)
);

CREATE TABLE payments (
    payment_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    invoice_id  INT           NOT NULL REFERENCES invoices(invoice_id),
    amount      NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    paid_on     DATE          NOT NULL DEFAULT CURRENT_DATE,
    method      VARCHAR(20)   NOT NULL
                CHECK (method IN ('cash', 'bank_transfer', 'card', 'mobile_money')),
    reference   VARCHAR(50)
);

CREATE TABLE discounts (
    discount_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    invoice_id   INT           NOT NULL REFERENCES invoices(invoice_id),
    reason       VARCHAR(100)  NOT NULL,
    amount       NUMERIC(10,2) NOT NULL CHECK (amount > 0)
);

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

INSERT INTO students (first_name, last_name, email, class_level)
VALUES ('Test', 'Student', 'test@example.com', 'JSS1');

INSERT INTO fee_types (name, default_amount)
VALUES ('Tuition', 50000);

SELECT student_id FROM students;
SELECT fee_type_id FROM fee_types;

INSERT INTO invoices (student_id, fee_type_id, amount, due_date)
VALUES (1, 1, 50000, '2026-12-01');

TRUNCATE students, fee_types, invoices, payments, discounts RESTART IDENTITY;

INSERT INTO students (first_name, last_name, email, class_level, enrolled_on) VALUES
('Chinedu',  'Okafor',   'chinedu.okafor@example.com',  'JSS1', '2026-09-01'),
('Amina',    'Bello',    'amina.bello@example.com',     'JSS2', '2025-09-08'),
('Tunde',    'Adeyemi',  'tunde.adeyemi@example.com',   'JSS3', '2024-09-09'),
('Grace',    'Johnson',  'grace.johnson@example.com',   'SS1',  '2025-09-08'),
('Ibrahim',  'Musa',     'ibrahim.musa@example.com',    'SS2',  '2024-09-09'),
('Funke',    'Ogunleye', 'funke.ogunleye@example.com',  'JSS1', '2026-09-01'),
('Emeka',    'Nwosu',    'emeka.nwosu@example.com',     'JSS2', '2025-09-08'),
('Halima',   'Yusuf',    'halima.yusuf@example.com',    'SS1',  '2025-09-08'),
('David',    'Eze',      'david.eze@example.com',       'JSS3', '2024-09-09'),
('Blessing', 'Akpan',    NULL,                          'SS2',  '2024-09-09');

INSERT INTO fee_types (name, default_amount) VALUES
('Tuition',  120000),
('Exam Fee',  15000),
('Bus Fee',   30000),
('Uniform',   25000);

INSERT INTO invoices (student_id, fee_type_id, amount, issued_on, due_date) VALUES
-- Tuition, term 1 (invoice IDs 1 to 8)
(1, 1, 120000, '2026-09-01', '2026-09-30'),
(2, 1, 120000, '2026-09-01', '2026-09-30'),
(3, 1, 120000, '2026-09-01', '2026-09-30'),
(4, 1, 120000, '2026-09-01', '2026-09-30'),
(5, 1, 120000, '2026-09-01', '2026-09-30'),
(6, 1, 120000, '2026-09-01', '2026-09-30'),
(7, 1, 120000, '2026-09-01', '2026-09-30'),
(8, 1, 120000, '2026-09-01', '2026-09-30'),
-- Exam fee (IDs 9 to 12)
(1, 2, 15000, '2026-09-01', '2026-10-05'),
(2, 2, 15000, '2026-09-01', '2026-10-05'),
(3, 2, 15000, '2026-09-01', '2026-10-05'),
(4, 2, 15000, '2026-09-01', '2026-10-05'),
-- Bus fee (IDs 13 to 15)
(2, 3, 30000, '2026-09-01', '2026-09-30'),
(5, 3, 30000, '2026-09-01', '2026-09-30'),
(7, 3, 30000, '2026-09-01', '2026-09-30'),
-- Uniform (IDs 16 to 18)
(9,  4, 25000, '2026-10-01', '2026-11-15'),
(10, 4, 25000, '2026-10-01', '2026-11-15'),
(3,  4, 25000, '2026-10-01', '2026-11-15'),
-- Tuition, issued later (IDs 19 and 20)
(9,  1, 120000, '2026-10-01', '2026-11-30'),
(10, 1, 120000, '2026-10-01', '2026-11-30');

INSERT INTO discounts (invoice_id, reason, amount) VALUES
(3,  'Sibling discount',     12000),
(7,  'Scholarship (20%)',    24000),
(20, 'Staff child discount', 30000);

INSERT INTO payments (invoice_id, amount, paid_on, method, reference) VALUES
(1,  120000, '2026-09-10', 'bank_transfer', 'TRF-0910-001'),
(2,   60000, '2026-09-15', 'cash',          'RCPT-0915-014'),
(2,   40000, '2026-10-02', 'mobile_money',  'MM-1002-077'),
(3,  108000, '2026-09-20', 'card',          'CRD-0920-032'),
(5,   50000, '2026-09-25', 'cash',          'RCPT-0925-021'),
(6,  120000, '2026-09-28', 'bank_transfer', 'TRF-0928-005'),
(7,   30000, '2026-10-01', 'mobile_money',  'MM-1001-040'),
(8,   70000, '2026-09-12', 'card',          'CRD-0912-009'),
(8,   50000, '2026-09-29', 'card',          'CRD-0929-044'),
(9,   15000, '2026-09-10', 'cash',          'RCPT-0910-003'),
(10,  15000, '2026-10-02', 'cash',          NULL),
(12,  15000, '2026-10-04', 'mobile_money',  'MM-1004-012'),
(13,  30000, '2026-09-20', 'cash',          'RCPT-0920-018'),
(15,  10000, '2026-10-03', 'cash',          NULL),
(16,  25000, '2026-10-05', 'bank_transfer', 'TRF-1005-002'),
(18,  25000, '2026-10-06', 'cash',          'RCPT-1006-007'),
(19,  60000, '2026-10-08', 'bank_transfer', 'TRF-1008-011'),
(20,  90000, '2026-10-09', 'card',          'CRD-1009-020');

SELECT
  (SELECT COUNT(*) FROM students)   AS students,
  (SELECT COUNT(*) FROM fee_types)  AS fee_types,
  (SELECT COUNT(*) FROM invoices)   AS invoices,
  (SELECT COUNT(*) FROM discounts)  AS discounts,
  (SELECT COUNT(*) FROM payments)   AS payments;

  SELECT
  (SELECT SUM(amount) FROM invoices)  AS total_invoiced,
  (SELECT SUM(amount) FROM discounts) AS total_discounts,
  (SELECT SUM(amount) FROM payments)  AS total_paid;

  CREATE VIEW invoice_balances AS
SELECT *, invoice_amount - discount_total - paid_total AS balance
FROM (
    SELECT i.invoice_id, i.student_id, i.fee_type_id, i.due_date,
           i.amount AS invoice_amount,
           COALESCE((SELECT SUM(d.amount) FROM discounts d
                     WHERE d.invoice_id = i.invoice_id), 0) AS discount_total,
           COALESCE((SELECT SUM(p.amount) FROM payments p
                     WHERE p.invoice_id = i.invoice_id), 0) AS paid_total
    FROM invoices i
) t;