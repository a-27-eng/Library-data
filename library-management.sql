CREATE DATABASE library_management;

USE library_management;

#Creating barnch table

CREATE TABLE branch(
branch_id	varchar(10) primary key,
manager_id varchar(10),
branch_address	varchar(55),
contact_no varchar(10)
);

#creating employee table
create table employee
(
emp_id varchar(10) primary key,
emp_name varchar(10),
position varchar(10),
salary	int,
branch_id varchar(10),
 foreign key (branch_id) references branch(branch_id)
);

create table books(
isbn varchar(20) primary key,
book_title	varchar(75),
category varchar(10),
rental_price float,
status	varchar(15),
author varchar(35),
publisher varchar(55)
);

create table member(
member_id varchar(10) primary key,
member_name varchar(35),
member_address	varchar(75),
reg_date date
);

create table issued_status(
issued_id	varchar(10) primary key,
issued_member_id	varchar(10),
issued_book_name	varchar(75),
issued_date	date,
issued_book_isbn varchar(25),
issued_emp_id varchar(10)
);

create table return_status
(
return_id	varchar(10),
issued_id	varchar(10),
return_book_name varchar(75),	
return_date	date,
return_book_isbn varchar(20)

);

ALTER TABLE issued_status
ADD CONSTRAINT fk_issued_member
FOREIGN KEY (issued_member_id)
REFERENCES member(member_id)
ON DELETE CASCADE;

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn)
ON DELETE CASCADE;

ALTER TABLE issued_status
ADD CONSTRAINT fk_empid
FOREIGN KEY (issued_emp_id)
REFERENCES  employee(emp_id )
ON DELETE CASCADE;

ALTER TABLE return_status
ADD CONSTRAINT fk_issue_status
FOREIGN KEY (issued_id)
REFERENCES  issued_status(issued_id )
ON DELETE CASCADE;


ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE books
MODIFY category VARCHAR(20);


ALTER TABLE issued_status
MODIFY issued_book_isbn VARCHAR(20);

ALTER TABLE issued_status
DROP FOREIGN KEY fk_books;

select * from branch;
SHOW TABLES;
RENAME TABLE employee TO employees;

select * from books;
select * from branch;
select * from employees;
select * from issued_status;
select * from member;
select * from return_status;

#Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;

#Task 2: Update an Existing Member's Address
UPDATE member
SET member_address = '125 Oak St'
WHERE member_id = 'C103';

#Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM issued_status
WHERE   issued_id =   'IS121';

#Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';

#Task 5: List Members Who Have Issued More Than One Book 
select issued_member_id,Count(*) 
from issued_status
group by 1
having count(*)>1;


select * from issued_status;
select * from books;

#Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
create table book_Cnts
as
select books.isbn,count(issued_status.issued_book_isbn) as no_issued
from books join issued_status 
on books.isbn=issued_status.issued_book_isbn
group by 1;

select * from book_Cnts;

#Task 7. Retrieve All Books in a Specific Category:
select * from books where category='Classic';

#Task 8: Find Total Rental Income by Category:
select * from books;
select * from issued_status;

select b.category,sum(b.rental_price) as total_price
from books b  join issued_status ist
on b.isbn=ist.issued_book_isbn
group by 1;

#task 8 List Members Who Registered in the Last 180 Days:
select * from member;
insert into member(member_id,member_name,member_address,reg_date)
values
('C120','Anusha','Bangalore','2025-07-18'),
('C121','Sid','Bangalore','2025-06-18');

select * from member where reg_date >= curdate() - interval 180 day;

#List Employees with Their Branch Manager's Name and their branch details:
select * from branch;
select * from employees;

select e1.* ,e2.emp_name as manager ,
b.branch_id from 
employees e1 
join
branch b
on b.branch_id=e1.branch_id
join 
employees e2
on b.manager_id=e2.emp_id;

#Task 11. Create a Table of Books with Rental Price Above a Certain Threshold like 7:
select * from books;
create table rental_7
as
select * from books where rental_price >7;

#Task 12: Retrieve the List of Books Not Yet Returned
select * from books;
select * from return_status;
select * from issued_status;

select ist.issued_book_name from
issued_status ist 
left join
return_status rts
on ist.issued_id=rts.issued_id
where rts.return_id is null;

#Task 13: Identify Members with Overdue Books
#Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.
#issued_status,member,books,return_status

select ist.issued_member_id,m.member_name,b.book_title,ist.issued_Date,rts.return_date,curdate()-ist.issued_date as overdule_Days
from 
issued_status ist 
join 
member m
on m.member_id=ist.issued_member_id
join
books b
on b.isbn=ist.issued_book_isbn
left join
return_status as rts
on rts.issued_id =ist.issued_id
where rts.return_date is null
and
(curdate()-ist.issued_date)>30;

#Task 14: Update Book Status on Return
#Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).

delimiter $$

create procedure add_return_records(in p_return_id varchar(10),in p_issued_id varchar (10))

begin
    declare v_isbn varchar(50);
	declare v_book_name varchar(80);

    insert into return_status(return_id,issued_id,return_date)
    values
    (p_return_id,p_issued_id,curdate());
    
    select issued_book_isbn ,issued_book_name
    into v_isbn,v_book_name
    from issued_status
    where issued_id=p_issued_id;
    
    update books
    set status='yes'
    where isbn=v_isbn;
    
   select concat('thank you for returning the book :',v_book_name) as message;
end$$

#issued id =IS135
#testing
select * from books where isbn ='978-0-307-58837-1';
select * from return_status where issued_id='IS135';
select * from return_status;
desc books;

call add_return_records('RS138','IS135');

#Task 15: Branch Performance Report
#Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

select * from branch;
select * from books;
select * from return_status;
select * from issued_status;
select * from employees;

select b.branch_id,b.manager_id,count(ist.issued_id) as number_of_books_issued,count(rs.return_id) as number_of_book_return ,sum(bk.rental_price) as total_revenue
from issued_status ist
join
employees e
on e.emp_id=ist.issued_emp_id
join
branch b
on e.branch_id=b.branch_id
left join
return_status rs
on rs.issued_id=ist.issued_id
join
books bk
on ist.issued_book_isbn=bk.isbn
group by 1,2;

#Task 16: CTAS: Create a Table of Active Members
#Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 years.

select * from issued_status;
select * from books;

create table active_members as
select * from member where member_id in(
select distinct issued_member_id
from issued_status ist
where issued_date >curdate()-interval 2 year);

select * from active_members;


#Task 17: Find Employees with the Most Book Issues Processed
#Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

select * from employees;
select * from issued_status;

select e.emp_name,b.*,count(ist.issued_id)
from issued_status ist
join
employees e
on e.emp_id=ist.issued_emp_id
join branch b
on e.branch_id = b.branch_id
group by 1,2;

#Task 18: Identify Members Issuing High-Risk Books
#Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.

select * from issued_status;
select * from books;
select * from return_status;

#Task 20: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
#Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. 
#The table should include: The number of overdue books. 
#The total fines, with each day's fine calculated at $0.50. The number of books issued by each member.
SELECT 
    m.member_id,
    
    -- Total books issued
    COUNT(ist.issued_id) AS total_books_issued,
    
    -- Number of overdue books
    SUM(
        CASE 
            WHEN rs.return_date IS NOT NULL 
                 AND DATEDIFF(rs.return_date, ist.issued_date) > 30 
            THEN 1 ELSE 0
        END
    ) AS overdue_books,
    
    -- Total fine amount
    SUM(
        CASE 
            WHEN rs.return_date IS NOT NULL 
                 AND DATEDIFF(rs.return_date, ist.issued_date) > 30 
            THEN (DATEDIFF(rs.return_date, ist.issued_date) - 30) * 1
            ELSE 0
        END
    ) AS total_fines,
    
    -- Longest delay in returning a book
MAX(DATEDIFF(rs.return_date, ist.issued_date)) AS max_days_between
    
FROM issued_status ist
JOIN books b
    ON b.isbn = ist.issued_book_isbn
LEFT JOIN return_status rs
    ON ist.issued_id = rs.issued_id
JOIN member m
    ON m.member_id = ist.issued_member_id
GROUP BY m.member_id;
