-- Спочатку рекомендую закоментувати все що не стосується умови 1, потім, після виконання цієї умови 
-- та завантаження даних, можна закоментувати умову 1 і виконати всі решту, тоді все запрацює чітко

-- Умова 1: створюємо схему та завантажуємо дані

CREATE SCHEMA IF NOT EXISTS pandemic;

USE pandemic;

-- Умова 2: нормалізуємо таблицю до 3 нормальної форми 

SELECT COUNT(*) FROM infectious_cases;

CREATE TABLE entities (
	id INT PRIMARY KEY UNIQUE AUTO_INCREMENT,
    entity_name VARCHAR(255) NOT NULL,
    code_name VARCHAR(45)
);

INSERT INTO entities (entity_name, code_name)
SELECT DISTINCT entity, code 
FROM infectious_cases;

ALTER TABLE infectious_cases
ADD code_id INT FIRST;

SET SQL_SAFE_UPDATES = 0;
UPDATE infectious_cases
JOIN entities SET infectious_cases.code_id = entities.id
WHERE infectious_cases.code = entities.code_name;

UPDATE infectious_cases 
SET
	Number_yaws = IF(Number_yaws='', NULL, Number_yaws),
    Number_rabies = IF(Number_rabies='', NULL, Number_rabies),
    Number_malaria = IF(Number_malaria='', NULL, Number_malaria),
    Number_hiv = IF(Number_hiv='', NULL, Number_hiv),
    Number_tuberculosis = IF(Number_tuberculosis='', NULL, Number_tuberculosis),
    Number_smallpox = IF(Number_smallpox='', NULL, Number_smallpox),
    Number_cholera_cases = IF(Number_cholera_cases='', NULL, Number_cholera_cases);
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE infectious_cases
DROP COLUMN entity,
DROP COLUMN code,
MODIFY COLUMN Number_yaws FLOAT,
MODIFY COLUMN Number_rabies FLOAT,
MODIFY COLUMN Number_malaria FLOAT,
MODIFY COLUMN Number_hiv FLOAT,
MODIFY COLUMN Number_tuberculosis FLOAT,
MODIFY COLUMN Number_smallpox FLOAT,
MODIFY COLUMN Number_cholera_cases FLOAT;

-- Умова 3: для кожної унікалької комбінації рахуємо середнє, мінімальне та максимальне значення атрибута Number_rabies
-- Результат сорсуємо за середнім у порядку спадання, виводимо 10 рядків на екран

SELECT 
	code_id, 
    AVG(Number_rabies) AS average, 
    MIN(Number_rabies) AS minimum, 
    MAX(Number_rabies) AS maximum,
    SUM(Number_rabies) AS total_sum
FROM infectious_cases
GROUP BY code_id
ORDER BY average DESC
LIMIT 10;

-- Умова 4: будуємо для нормованої таблиці атрибут, що створює дату першого січня відповідного року,
-- атрибут, що дорівнює поточній даті, атрибут, що дорівнює різниці в роках двох вищезгаданих колонок.

SELECT 
	code_id, 
	year,
	MAKEDATE(year, 1) AS date_format,
	CURDATE() AS today,
    TIMESTAMPDIFF(YEAR, MAKEDATE(year, 1), CURDATE()) AS different
FROM infectious_cases;

-- Умова 5: Створіть і використайте функцію, що будує такий же атрибут, як і в попередньому 
-- завданні: функція має приймати на вхід значення року, а повертати різницю в роках між 
-- поточною датою та датою, створеною з атрибута року (1996 рік → ‘1996-01-01’).

DROP FUNCTION IF EXISTS difer_between_year;

DELIMITER //
CREATE FUNCTION difer_between_year(year INT)
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE result INT;
    SET result = TIMESTAMPDIFF(YEAR, MAKEDATE(year, 1), CURDATE());
    RETURN result;
END //
DELIMITER ;

SELECT code_id, year, difer_between_year(year) AS different FROM infectious_cases;