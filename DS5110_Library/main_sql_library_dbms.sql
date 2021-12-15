-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema library
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `library` ;

-- -----------------------------------------------------
-- Schema library
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `library` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `library` ;

-- -----------------------------------------------------
-- Table `library`.`books`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `library`.`books` ;

CREATE TABLE IF NOT EXISTS `library`.`books` (
  `bookID` INT NOT NULL,
  `title` TEXT NULL DEFAULT NULL,
  `authors` TEXT NULL DEFAULT NULL,
  `average_rating` DOUBLE NULL DEFAULT NULL,
  `isbn` TEXT NULL DEFAULT NULL,
  `isbn13` BIGINT NULL DEFAULT NULL,
  `language_code` TEXT NULL DEFAULT NULL,
  `num_pages` INT NULL DEFAULT NULL,
  `ratings_count` INT NULL DEFAULT NULL,
  `text_reviews_count` INT NULL DEFAULT NULL,
  `publication_date` TEXT NULL DEFAULT NULL,
  `publisher` TEXT NULL DEFAULT NULL,
  PRIMARY KEY (`bookID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `library`.`bookitem`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `library`.`bookitem` ;

CREATE TABLE IF NOT EXISTS `library`.`bookitem` (
  `ID` VARCHAR(5) NOT NULL,
  `bookID` INT NOT NULL,
  `quantity` INT(2) UNSIGNED ZEROFILL NOT NULL DEFAULT '00',
  PRIMARY KEY (`ID`),
  INDEX `bookID` (`bookID` ASC) VISIBLE,
  CONSTRAINT `bookitem_ibfk_1`
    FOREIGN KEY (`bookID`)
    REFERENCES `library`.`books` (`bookID`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `library`.`employees`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `library`.`employees` ;

CREATE TABLE IF NOT EXISTS `library`.`employees` (
  `ID` INT NULL DEFAULT NULL,
  `name` TEXT NULL DEFAULT NULL,
  `position` TEXT NULL DEFAULT NULL,
  `hire_date` DATETIME NULL DEFAULT NULL,
  `salary` INT NULL DEFAULT NULL,
  `phone_number` TEXT NULL DEFAULT NULL)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `library`.`patrons`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `library`.`patrons` ;

CREATE TABLE IF NOT EXISTS `library`.`patrons` (
  `ID` INT NOT NULL,
  `name` TEXT NOT NULL,
  `status` TEXT NULL DEFAULT NULL,
  `phone` TEXT NULL DEFAULT NULL,
  `fee` DECIMAL(6,2) UNSIGNED ZEROFILL NULL DEFAULT '0000.00',
  PRIMARY KEY (`ID`),
  UNIQUE INDEX `ID_UNIQUE` (`ID` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `library`.`lending`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `library`.`lending` ;

CREATE TABLE IF NOT EXISTS `library`.`lending` (
  `ID` INT NOT NULL,
  `item_id` INT NOT NULL,
  `date` DATE NOT NULL,
  PRIMARY KEY (`ID`, `item_id`),
  INDEX `item_id` (`item_id` ASC) VISIBLE,
  CONSTRAINT `lending_ibfk_1`
    FOREIGN KEY (`ID`)
    REFERENCES `library`.`patrons` (`ID`)
    ON DELETE CASCADE,
  CONSTRAINT `lending_ibfk_2`
    FOREIGN KEY (`item_id`)
    REFERENCES `library`.`bookitem` (`bookID`)
    ON DELETE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

USE `library` ;

-- -----------------------------------------------------
-- Placeholder table for view `library`.`admin`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `library`.`admin` (`ID` INT, `name` INT, `position` INT, `hire_date` INT, `salary` INT, `phone_number` INT);

-- -----------------------------------------------------
-- Placeholder table for view `library`.`hr`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `library`.`hr` (`name` INT, `position` INT, `hire_date` INT, `phone_number` INT);

-- -----------------------------------------------------
-- Placeholder table for view `library`.`librarian`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `library`.`librarian` (`name` INT, `position` INT, `phone_number` INT);

-- -----------------------------------------------------
-- procedure count_out
-- -----------------------------------------------------

USE `library`;
DROP procedure IF EXISTS `library`.`count_out`;

DELIMITER $$
USE `library`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `count_out`()
BEGIN
	SELECT COUNT(*) AS books_out FROM library.lending;
	END$$

DELIMITER ;

-- -----------------------------------------------------
-- function display_best_book
-- -----------------------------------------------------

USE `library`;
DROP function IF EXISTS `library`.`display_best_book`;

DELIMITER $$
USE `library`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `display_best_book`() RETURNS text CHARSET utf8mb4
    DETERMINISTIC
BEGIN
	DECLARE best_book text;
	SELECT title INTO best_book
	FROM books
    WHERE average_rating = (SELECT MAX(average_rating) FROM books);
    RETURN best_book;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- function display_fees
-- -----------------------------------------------------

USE `library`;
DROP function IF EXISTS `library`.`display_fees`;

DELIMITER $$
USE `library`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `display_fees`() RETURNS decimal(10,0)
    DETERMINISTIC
BEGIN
	DECLARE max_fee decimal;
	SELECT MAX(fee) INTO max_fee
	FROM patrons;
    RETURN max_fee;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- function display_worst_employee
-- -----------------------------------------------------

USE `library`;
DROP function IF EXISTS `library`.`display_worst_employee`;

DELIMITER $$
USE `library`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `display_worst_employee`() RETURNS text CHARSET utf8mb4
    DETERMINISTIC
BEGIN
	DECLARE worst_employee text;
	SELECT name INTO worst_employee
	FROM employees
    WHERE salary = (SELECT MAX(salary) FROM employees);
    RETURN worst_employee;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure lent_books
-- -----------------------------------------------------

USE `library`;
DROP procedure IF EXISTS `library`.`lent_books`;

DELIMITER $$
USE `library`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `lent_books`(
	IN ID INT
)
BEGIN
SELECT patrons.name, patrons.status, patrons.phone, patrons.fee
FROM patrons
INNER JOIN lending ON patrons.ID=lending.ID
WHERE patrons.ID = ID;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure longest_books
-- -----------------------------------------------------

USE `library`;
DROP procedure IF EXISTS `library`.`longest_books`;

DELIMITER $$
USE `library`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `longest_books`()
BEGIN
SELECT *
FROM books
ORDER BY num_pages DESC
LIMIT 5;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure most_prolific
-- -----------------------------------------------------

USE `library`;
DROP procedure IF EXISTS `library`.`most_prolific`;

DELIMITER $$
USE `library`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `most_prolific`()
BEGIN
	SELECT authors, count(distinct(isbn)) as books_written
	FROM books
	GROUP BY authors
	ORDER BY books_written DESC
	LIMIT 5;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure oldest_books
-- -----------------------------------------------------

USE `library`;
DROP procedure IF EXISTS `library`.`oldest_books`;

DELIMITER $$
USE `library`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `oldest_books`()
BEGIN
SELECT *
FROM books
ORDER BY publication_date DESC
LIMIT 5;

END$$

DELIMITER ;

-- -----------------------------------------------------
-- View `library`.`admin`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `library`.`admin`;
DROP VIEW IF EXISTS `library`.`admin` ;
USE `library`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `library`.`admin` AS select `library`.`employees`.`ID` AS `ID`,`library`.`employees`.`name` AS `name`,`library`.`employees`.`position` AS `position`,`library`.`employees`.`hire_date` AS `hire_date`,`library`.`employees`.`salary` AS `salary`,`library`.`employees`.`phone_number` AS `phone_number` from `library`.`employees`;

-- -----------------------------------------------------
-- View `library`.`hr`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `library`.`hr`;
DROP VIEW IF EXISTS `library`.`hr` ;
USE `library`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `library`.`hr` AS select `library`.`employees`.`name` AS `name`,`library`.`employees`.`position` AS `position`,`library`.`employees`.`hire_date` AS `hire_date`,`library`.`employees`.`phone_number` AS `phone_number` from `library`.`employees`;

-- -----------------------------------------------------
-- View `library`.`librarian`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `library`.`librarian`;
DROP VIEW IF EXISTS `library`.`librarian` ;
USE `library`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `library`.`librarian` AS select `library`.`employees`.`name` AS `name`,`library`.`employees`.`position` AS `position`,`library`.`employees`.`phone_number` AS `phone_number` from `library`.`employees`;
USE `library`;

DELIMITER $$

USE `library`$$
DROP TRIGGER IF EXISTS `library`.`lending_AFTER_INSERT` $$
USE `library`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `library`.`lending_AFTER_INSERT`
AFTER INSERT ON `library`.`lending`
FOR EACH ROW
BEGIN
	update patrons, lending
	set patrons.status = 'hold'
	where patrons.ID = lending.ID;
END$$


DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;