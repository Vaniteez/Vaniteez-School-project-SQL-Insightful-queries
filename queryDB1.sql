use classicmodels;
#1.1
#Revenue made by product 

select productCode, quantityOrdered, priceEach, 
(priceEach*quantityOrdered) as productRevenue
from orderdetails
order by productRevenue desc;

#What products have the biggest buy price and who are the vendors

select productName, buyPrice, productVendor
from products
order by buyPrice asc;

#Where are located the customers

select customerNumber, city, country, postalCode
from customers
order by country asc,city asc;

#where are located our offices

select officeCode, city, country, postalCode
from offices
order by country asc,city asc;

#Employee per job titles

select jobTitle, count(employeeNumber) as employeeCount
from employees
group by jobTitle
order by jobTitle asc;

#1.2
# Employee with the most customers at charge

select e.employeeNumber, e.firstName, e.lastName, count(c.salesRepEmployeeNumber) as numberOfCustomerAtCharge
from employees e
join customers c
on e.employeeNumber = c.salesRepEmployeeNumber
group by e.employeeNumber, e.firstName, e.lastName
order by numberOfCustomerAtCharge desc;

#average amount per customer

select c.customerNumber, c.customerName, SUM(p.amount) as totalAmount, COUNT(o.orderNumber) as numberOfOrders, 
(SUM(p.amount) / COUNT(o.orderNumber)) as averageOrderAmount
from customers c
join payments p using (customerNumber)
join orders o using (customerNumber)
group by c.customerNumber, c.customerName
order by totalAmount desc;


#1.3

# Subquery in SELECT : Find the biggest client, that didnt order since 2004

select c.customerNumber, c.customerName,
		(select sum(p.amount)
        from payments p 
        join orders o
        on o.customerNumber = p.customerNumber
        where p.customerNumber = c.customerNumber
        and o.orderDate <= '2005-01-01') as totalPayment, ## peut être pas nécessaire
         (select max(o.orderDate)
        from orders o
        where c.customerNumber = o.customerNumber 
        and o.orderDate <= '2005-01-01') as lastPayment
from customers c
having lastPayment is not null
order by totalPayment desc;
        
# Subqueries in WHERE and FROM . Find the customers, who have bigger payment during christmas time than their average
# payments

select c.customerNumber, c.customerName, christmasPayments.paymentDate, christmasPayments.amount,
(select avg(p.amount)
from payments p
where p.customerNumber = c.customerNumber) as yearAvg
from customers c
join (
    select p.customerNumber, p.paymentDate, p.amount
    from payments p
    where month(p.paymentDate) between 11 and 12
) as christmasPayments on c.customerNumber = christmasPayments.customerNumber
where christmasPayments.amount > (
    select avg(p.amount) as avgAmount
    from payments p
    where p.customerNumber = c.customerNumber)
    order by christmasPayments.amount desc;
    


#1.4

# where are the customers who spend the most

select c.customerNumber, c.country, p.amount,
min(amount) over(partition by c.country) as minAmount,
max(amount) over(partition by c.country) as maxAmount,
avg(p.amount) over(partition by c.country) as countryAvg,
avg(p.amount) over() as globalAvg,
rank() over(order by p.amount desc) as overallRank
from payments p
join customers c
on p.customerNumber = c.customerNumber
where c.country is not null;

#Profit comparison per items

with productsData as (
select distinct p.productCode, p.productName, p.buyPrice,
sum(od.quantityOrdered) over(partition by p.productCode) as totalQuantityOrdered,
avg(od.priceEach) over(partition by p.productCode) as avgPriceEach,
avg(od.quantityOrdered * od.priceEach - p.buyPrice * od.quantityOrdered) over() as globalAvgRevenue,
avg(od.quantityOrdered * od.priceEach - p.buyPrice * od.quantityOrdered) over(partition by productCode) as productAvgRevenue
from products p 
join orderdetails od
on p.productcode = od.productcode
order by productAvgRevenue desc)

select distinct productCode, productName, buyPrice, totalQuantityOrdered, avgPriceEach, globalAvgRevenue, 
productAvgRevenue,
rank() over (order by productAvgRevenue desc) as productRank
from productsData;






