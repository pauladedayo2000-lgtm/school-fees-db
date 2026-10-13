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
