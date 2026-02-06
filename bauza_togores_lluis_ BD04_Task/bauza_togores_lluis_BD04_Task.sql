use classicmodels;

/* 1. What is the purchase price, quantity in stock, and product name of the product with
the highest purchase price? */
SELECT 
    buyPrice, quantityInStock, productName
FROM
    products
WHERE
    buyPrice IN (SELECT 
            MAX(buyPrice)
        FROM
            products);

/*2. Show customers living on a Lane (with an address containing 'Lane' or 'Ln.') and
whose credit limit is greater than 80,000.*/
SELECT 
    *
FROM
    customers
WHERE
    UPPER(addressLine1) REGEXP 'Lane'
        OR UPPER(addressLine1) REGEXP 'Ln'
        AND creditLimit > 80000;

/*3. Show products (name and code) along with the number of orders they are included
in, only if the product is in more than 50 orders. Then, display products in descending
order by the number of orders.*/
SELECT 
    products.productCode,
    products.productName,
    COUNT(*) NumberOfOrders
FROM
    products
        JOIN
    orderdetails ON (products.productCode = orderdetails.productCode)
GROUP BY products.productCode
HAVING COUNT(*) > 50
ORDER BY NumberOfOrders DESC;

/*4. Find the customer name, customer number, and payment amount for those payments
made in 2005 with an amount greater than 100,000.*/
SELECT 
    customers.customerName,
    customers.customerNumber,
    payments.amount
FROM
    customers
        JOIN
    payments ON (customers.customerNumber = payments.customerNumber)
WHERE
    YEAR(paymentDate) = 2005
        AND amount > 100000;

/*5. Find the customer name and payment date of customers who made payments
managed by employees assigned to the San Francisco office. Sort results by payment
date.*/
SELECT 
    customers.customerName, payments.paymentDate
FROM
    customers
        JOIN
    employees ON (customers.salesRepEmployeeNumber = employees.employeeNumber)
        JOIN
    payments ON customers.customerNumber = payments.customerNumber
        JOIN
    offices ON (employees.officeCode = offices.officeCode)
WHERE
    offices.city = 'San Francisco'
ORDER BY payments.paymentDate;

/*6. Find the name and customer number for those who made payments one day before
or after 2004-11-16.*/
SELECT 
    customers.customerNumber, customers.customerName
FROM
    customers
        JOIN
    payments ON customers.customerNumber = payments.customerNumber
WHERE
    payments.paymentDate IN ('2004-11-15' , '2004-11-17');

/*7. Find all products (all fields) where the product line description contains the word
"Vintage" and the product description contains the word "tires."*/
SELECT 
    products.*
FROM
    products
        JOIN
    productLines ON products.productLine = productlines.productLine
WHERE
    UPPER(products.productDescription) REGEXP 'TIRES'
        AND UPPER(productlines.textDescription) REGEXP 'VINTAGE';

/*8. Show the office name (with alias department) and the employee's name for those
employees who has not any customers assigned and whose office is in Japan.*/
SELECT 
    offices.city 'Department',
    CONCAT(employees.firstName,
            ' ',
            employees.lastName)
FROM
    offices
        JOIN
    employees ON offices.officeCode = employees.officeCode
        LEFT JOIN
    customers ON employees.employeeNumber = customers.salesRepEmployeeNumber
WHERE
    offices.country = 'Japan'
        AND customers.salesRepEmployeeNumber IS NULL; 

/*9. Find all data of employees belonging to office with code 6 whose customers have not
made any payment.*/
SELECT 
    employees.*
FROM
    employees
        JOIN
    customers ON employees.employeeNumber = customers.salesRepEmployeeNumber
        LEFT JOIN
    payments ON customers.customerNumber = payments.customerNumber
WHERE
    employees.officeCode = '6'
        AND payments.customerNumber IS NULL; 
        
/*10. Show the name of the office (as department) and the number of employees in each
office, ordering results from highest to lowest number of employees.*/
SELECT 
    offices.city Department,
    COUNT(employees.employeeNumber) AS NumberOfEmployees
FROM
    offices
        JOIN
    employees ON employees.officeCode = offices.officeCode
GROUP BY Department
ORDER BY NumberOfEmployees DESC; 

/*11. Show the number of orders placed each month of the year, ordered from January to
December.*/
SELECT 
    EXTRACT(MONTH FROM orderDate) AS Month,
    COUNT(*) AS OrderPerMonth
FROM
    orders
GROUP BY Month
ORDER BY Month;

/*12. Find the employee number, first name, and last name of employees managing
customers with payments exceeding 100,000 euros, ordering employees by
employeeNumber.*/
SELECT DISTINCT
    employees.employeeNumber,
    employees.firstName,
    employees.lastName
FROM
    employees
        JOIN
    customers ON employees.employeeNumber = customers.salesRepEmployeeNumber
        JOIN
    payments ON customers.customerNumber = payments.customerNumber
WHERE
    payments.amount > 100000
ORDER BY employees.employeeNumber;

/*13. Show employees from the USA who do not have assigned customers.*/
SELECT 
    employees.*
FROM
    EMPLOYEES
        JOIN
    offices ON employees.officeCode = offices.officeCode
        LEFT JOIN
    customers ON employees.employeeNumber = customers.salesRepEmployeeNumber
WHERE
    offices.country = 'USA'
        AND customers.salesRepEmployeeNumber IS NULL;

/*14. How many years have passed since the older orders was placed? Show the order
number, customer number, and the years passed as antiquity.*/
SELECT 
    orderNumber,
    customerNumber,
    EXTRACT(YEAR FROM SYSDATE()) - EXTRACT(YEAR FROM orderDate) 'Antiquity'
FROM
    orders
ORDER BY OrderDate
LIMIT 1;

/*15. Show the total number of payments, the minimum amount, and the maximum
amount among all payments.*/
SELECT 
    COUNT(*) NumberOfPayments,
    MAX(amount) MaximumAmount,
    MIN(amount) MinimumAmount
FROM
    payments;

/*16. Find the employee ID, first name, and number of customers managed by each
employee, only for employees with assigned customers that made payments below
3,000 euros.*/
SELECT 
    employees.employeeNumber,
    employees.firstName,
    COUNT(DISTINCT customers.customerNumber) AS NumberOfCustomers
FROM
    employees
        JOIN
    customers ON employees.employeeNumber = customers.salesRepEmployeeNumber
        JOIN
    payments ON customers.customerNumber = payments.customerNumber
WHERE
    payments.amount < 3000
GROUP BY employees.employeeNumber;

/*17. Select payments (check number and amount) of customers managed by employees
in the NYC office, classifying them by amount as:
 Over 50,000: 'Very high payment'
 Between 15,000 and 50,000: 'Medium payment'
 Less than 15,000: 'Low payment'*/
SELECT 
    payments.checkNumber,
    payments.amount,
    CASE
        WHEN payments.amount < 15000 THEN 'Low payment'
        WHEN payments.amount BETWEEN 15000 AND 50000 THEN 'Medium Payment'
        ELSE 'Very high payment'
    END AS AmountClassification
FROM
    payments
        JOIN
    customers ON customers.customerNumber = payments.customerNumber
        JOIN
    employees ON customers.salesRepEmployeeNumber = employees.employeeNumber
        JOIN
    offices ON employees.officeCode = offices.officeCode
WHERE
    offices.city = 'NYC';

/*18. Show a list with the branch name (city), first name, and last name of employees
working there, ordered by branch and last name.*/
SELECT 
    offices.city AS 'Branch Name',
    employees.firstName,
    employees.lastName
FROM
    offices
        JOIN
    employees ON offices.officeCode = employees.officeCode
ORDER BY offices.city , employees.lastName;

/*19. Show the office name of employees who have managed orders placed by the
customer "Atelier graphique."*/
SELECT DISTINCT
    offices.city AS 'Office Name'
FROM
    offices
        JOIN
    employees ON employees.officeCode = offices.officeCode
        JOIN
    customers ON employees.employeeNumber = customers.salesRepEmployeeNumber
        JOIN
    orders ON customers.customerNumber = orders.customerNumber
WHERE
    UPPER(customers.customerName) = 'ATELIER GRAPHIQUE';

/*20. Show the first name, last name, and job title of employees who do not have the title
"Sales Rep." Add a column with their boss's full name. Employees without a boss
should also be listed.*/
SELECT 
    e1.firstName,
    e1.lastName,
    e1.jobTitle,
    CONCAT(e2.firstName, ' ', e2.lastName) AS BossName
FROM
    employees e1
        LEFT JOIN
    employees e2 ON e1.reportsTo = e2.employeeNumber
WHERE
    e1.jobTitle <> 'Sales Rep';

/*21. Show the name of all offices and the total amount of money in orders managed by
employees in each office.*/
SELECT 
    offices.city,
    SUM(orderdetails.quantityOrdered * orderdetails.priceEach) AS 'Total Amount'
FROM
    offices
        JOIN
    employees ON offices.officeCode = employees.officeCode
        JOIN
    customers ON employees.employeeNumber = customers.salesRepEmployeeNumber
        JOIN
    orders ON customers.customerNumber = orders.customerNumber
        JOIN
    orderdetails ON orders.orderNumber = orderdetails.orderNumber
GROUP BY offices.city;

/*22. Show the name of Japanese customers who bought products of the "Classic Cars"
product line, and the first and last name of the employees who assigned to them.*/
SELECT DISTINCT
    customers.customerName,
    employees.firstName,
    employees.lastName
FROM
    customers
        JOIN
    orders ON customers.customerNumber = orders.customerNumber
        JOIN
    orderdetails ON orders.orderNumber = orderdetails.orderNumber
        JOIN
    products ON orderdetails.productCode = products.productCode
        JOIN
    productLines ON products.productLine = productLines.productLine
        JOIN
    employees ON employees.employeeNumber = customers.salesRepEmployeeNumber
WHERE
    customers.country = 'JAPAN'
        AND productLines.productLine = 'Classic Cars'; 

/*23. Show the cities of offices (as office_city) that have at least one employee with five
assigned customers.*/
SELECT DISTINCT
    offices.city AS office_city
FROM
    offices
        JOIN
    employees ON offices.officeCode = employees.officeCode
        JOIN
    customers ON employees.employeeNumber = customers.salesRepEmployeeNumber
WHERE
    employees.employeeNumber IN (SELECT 
            employees.employeeNumber
        FROM
            employees
                JOIN
            customers ON employees.employeeNumber = customers.salesRepEmployeeNumber
        GROUP BY employees.employeeNumber
        HAVING COUNT(customers.salesRepEmployeeNumber) >= 5);
    
/*24. Show the order number and date of orders for products of type "Planes," placed by
customers who have made exactly two orders and with orders in May 2024.*/
SELECT DISTINCT
    orders.orderNumber, orders.orderDate
FROM
    orders
        JOIN
    orderdetails ON orders.orderNumber = orderdetails.orderNumber
        JOIN
    products ON orderdetails.productCode = products.productCode
        JOIN
    customers ON orders.customerNumber = customers.customerNumber
WHERE
    products.productLine = 'Planes'
        AND YEAR(orders.orderDate) = '2024'
        AND MONTH(orders.orderDate) = '5'
        AND customers.customerNumber IN (SELECT 
            customers.customerNumber
        FROM
            orders
                JOIN
            customers ON orders.customerNumber = customers.customerNumber
        GROUP BY customers.customerNumber
        HAVING COUNT(orders.orderNumber) = 2);

/*25. How many customers are there for each combination of office city and order status?*/
SELECT 
    offices.city,
    orders.status,
    COUNT(DISTINCT customers.customerNumber)
FROM
    offices
        JOIN
    employees ON offices.officeCode = employees.officeCode
        JOIN
    customers ON employees.employeeNumber = customers.salesRepEmployeeNumber
        JOIN
    orders ON customers.customerNumber = orders.customerNumber
GROUP BY offices.city , orders.status;
