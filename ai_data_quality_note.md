# AI Data-Quality Note

## How AI was used
I used Claude (an AI assistant) to help design the five tables, write the sample data, and draft the SQL queries and the data-quality checks. I ran everything myself in PostgreSQL 18 through pgAdmin and compared the results with the totals I expected. For example, the outstanding balance came to 426,000 in the queries, which matched the total from invoices minus discounts minus payments.

## Checks run
1. Students with no email address
2. Payments with no reference number
3. Invoices where the balance is below zero (overpaid or over-discounted)
4. Payments dated before the invoice was issued
5. Students with no invoices

## Findings
- Check 1: 1 student has no email (Blessing Akpan, student 10).
- Check 2: 2 payments have no reference number (payments 11 and 14). Both are cash payments.
- Checks 3, 4 and 5 returned 0 rows. There are no overpaid invoices, no payments dated before their invoice, and no students without a bill.

## What I did about it
- Missing email: the schema allows an empty email, so the record is valid. The school should collect an email later so it can send fee reminders.
- Missing references: cash payments without a receipt number cannot be traced. I recommend requiring a reference for every cash payment in future entries.
- I did not change the sample data. I kept the gaps to show that the checks find them.

## Limits
The sample data is invented, and the gaps in checks 1 and 2 were included on purpose to test the checks. These checks cover missing values and basic logic. They do not detect duplicate students, misspelled names, or wrong amounts that still look valid. In a real school, I would run them again on real data.