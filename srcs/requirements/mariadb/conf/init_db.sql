--creat new database
CREATE DATABASE IF NOT EXISTS ${MARIADB_DATABASE};

--switch to database
USE ${MARIADB_DATABASE};

--creat new table
CREATE TABLE users(
	id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	email VARCHAR(100) NOT NULL UNIQUE,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--insert sample datas
INSERT INTO users (name, email) VALUES
('miouz', 'blabla@lol.com'), 
('mioua', 'bloublou@lol.com');




