GRANT ALL PRIVILEGES ON *.* TO 'rails-app'@'%' IDENTIFIED BY 'password';
REVOKE SUPER ON *.* FROM 'rails-app'@'%';
