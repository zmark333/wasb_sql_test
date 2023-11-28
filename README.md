
I... I don't feel so good.

I barely remember anything. Did Ian dance on the table with a carrot in his mouth? Was Alex singing karaoke with Santa 
Claus? Umberto was _definitely_ handing out Silverbullet-branded gifts to strangers.

I _think_ we might have overdone it at the company Christmas party.

Still though, we should be fine. Let me grab some water, and then we can get to work adding all of the expenses from 
last night into the finance system.

...what do you mean the finance system is gone?... Tim traded it for mince pies and warm milk?... Oh no...

---

We need to rebuild the "(S)ilverbullet (Ex)penses and (I)voices" system, or SExI for short. SExI uses the 
[Trino](https://trino.io/docs/current/index.html) engine, a distributed SQL engine for big data querying.

While Andrea chases those dastardly reindeer down to recover our production server, we'll make do with an in-memory 
database for now, and upload all of our SQL code a fork of this repo. Once we've got our hardware back, we can run these 
sql files against the real database and pretend nothing bad ever happened!

Let's get the repo forked and Trino installed. We can download a shiny new copy of the db engine from docker. 

1. Fork this github repo.
2. Download and install docker desktop. Instructions can be found [here](https://www.docker.com/products/docker-desktop/).
3. Start the SExI container, by running `docker run --name=sexi-silverbullet -d trinodb/trino` at a terminal
4. You can reset the database at any time by running `docker restart sexi-silverbullet` at a terminal
5. You can access a trino SQL shell using `docker exec -it sexi-silverbullet trino`. Here you can run any SQL commands 
you like, as long as they're supported by trino.
When interacting with trino, `USE` the `memory.default` catalogue.schema.

#

Okay, good start. We have the database server. Now we need to add some data.

Let's start by adding all of the employees to the SExI database, in an `EMPLOYEE` table. 

1. Create an `EMPLOYEE` table using the data in the `hr/employee_index.csv` file. Add all of the data as it appears 
in the file to the table.
2. Set the `exployee_id` and `manager_id` columns to the `TINYINT` data type.
5. Add all of the SQL queries you wrote for this task into the `create_employees.sql` file. Make sure the file is a 
valid SQL file. 

#

Nice one, that feels better already. Next we need to add the receipts we've got last night into an expenses table. As 
more and more of the team wake up from their ~~hangovers~~ slumber and submit their expenses, we'll need to add more 
data to this table.

1. Create a SExI `EXPENSE` table with the following columns:
    - `employee_id TINYINT`
    - `unit_price DECIMAL(8, 2)`
    - `quantity TINYINT`
2. Add the data from the `finance/receipts_from_last_night` directory into the table.
3. Add all of the SQL queries you wrote for this task into the `create_expenses.sql` file. Make sure the file is a 
valid SQL file. 

# 

I guess you know what we need to do next; the suppliers. Thankfully, they've all been very diligent, and submitted 
their invoices promptly. I sure hope we didn't spend too much on all of that extravagant entertainment last night; the 
vodka ice luge was spectacular though...

1. Create a SExI `INVOICE` table with the following columns:
    - `supplier_id TINYINT`
    - `invoice_ammount DECIMAL(8, 2)`
    - `due_date DATE`
2. Create a SExI `SUPPLIER` table with the following columns:
    - `supplier_id TINYINT`
    - `name VARCHAR`
3. Add the data from the `finance/invoices_due` directory into the `INVOICE` table. 
    - The data doesn't have supplier ids, only the company names. Create a supplier_id for each supplier sorted 
    alphabetically.
    - we always pay invoices on the last day of the month. Each `due_date` should be the last day of any given month.
4. Add all of the SQL queries you wrote for this task into the `create_invoices.sql` file. Make sure the file is a 
valid SQL file. 

#

This is great! We're almost done! While you were creating the tables, our HR team reached out to me to make sure that 
everyone in the company has a manager that can approve their expenses.

1. Create a SQL query to check for cycles of employees who approve each others expenses in SExI. The results should contain a 2 columns, one of the employee_id 
in the loop, and then a column representing the loop itself (array or comma separated employee_ids, for example. You choose.) 
2. Add all of the SQL queries you wrote for this task into the `find_manager_cycles.sql` file. Make sure the file is a 
valid SQL file. 

# 

Uh oh! The Chief of Staff has reached out, and they are _angry_! Apparently, some employees have expensed a _lot_ more 
than is outlined in the company handbook, and they want to know who's responsible!

1. Create a SQL query to report the `employee_id`, `employee_name`, `manager_id`, `manager_name` and 
`total_expensed_amount` for anybody who's expensed more than 1000 of goods or services in SExI. Order the offenders by the 
`total_expensed_amount` in descending order.
    - the `expensed_amount` of an `EXPENSE` is the `EXPENSE.unit_price * EXPENSE.quantity`.
    - the `total_expensed_amount` of an `EMPLOYEE` is the `SUM` of the `expensed_amount`s for all `EXPENSE`s with their 
    `employee_id`.
    - the `employee_name` is the `EMPLOYEE.first_name` and `EMPLOYEE.last_name` separated by a space (`" "`) of the 
    employee having the `employee_id`.
    - the `manager_name`is the `EMPLOYEE.first_name` and `EMPLOYEE.last_name` separated by a space (`" "`) of the 
    `EMPLOYEE` having `EMPLOYEE.employee_id = manager_id`.
2. Add all of the SQL queries you wrote for this task into the `calculate_largest_expensors.sql` file. Make sure the 
file is a valid SQL file. 

# 

Phew, i'm glad we've got that all figured out. Finance rang while you were working out the expenses and asked for a 
favour. Apparently they had a little too much brandy sauce with dessert last night, and, well, they can't seem to login 
to their computers, too much fondant in the keyboard. They've asked us to come up with a monthly payment plan for our 
invoices.

This probably feels really confusing. But i'm pretty good with a pen and paper, so i've jotted down our catering 
payment plan so you can check your work:
```
 SUPPLIER_ID |     SUPPLIER_NAME     | PAYMENT_AMOUNT | BALANCE_OUTSTANDING | PAYMENT_DATE
-------------+-----------------------+----------------+---------------------+--------------
           1 | Catering Plus         |        1500.00 |             2000.00 | End of this month
           1 | Catering Plus         |        1500.00 |              500.00 | End of next month
           1 | Catering Plus         |         500.00 |                0.00 | End of the month after
```

1. Create a SQL query to report the `supplier_id`, `supplier_name`, `payment_amount`, `balance_outstanding`, 
`payment_date` for each of our suppliers/invoices in SExI.
    - `supplier_name` is the `SUPPLIER.name` of the `SUPPLIER.supplier_id`.
    - `payment_amount` should be the sum of all appropriate uniform monthly payments to fully pay the `SUPPLIER` for 
    any `INVOICE` 
    before the `INVOICE.due_date`. If a supplier has multiple invoices, the aggregate monthly payments may be uneven. 
    - `balance_outstanding` is the total balance outstanding across ALL `INVOICE`s for the `SUPPLIER.supplier_id`.
    - `date` should be the last day of the month for any payment for any invoice.
    - `SUPPLIER`s with multiple invoices should receive 1 payment per month. 
    - payments start at the end of this month.
2. Add all of the SQL queries you wrote for this task into the `generate_supplier_payment_plans.sql` file. Make sure 
the file is a valid SQL file. 

#

Awesome! Finance will be so happy with us! Our tech guys are still rebuilding the production database, so upload your 
code to github and take the rest of the afternoon off to ~~recover~~ relax!

1. Upload all of your code to your forked github repo in a new branch, and create a pull request with your changes into 
the main branch.
2. Share your branch name with your recruiting contact, who will be in touch regarding the results of your test.
