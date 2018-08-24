# noinspection SqlNoDataSourceInspectionForFile

# ~~~ MYSQL COMMAND ~~~
# mysql -p48115

# create database avtonew;
# create user 'avtonew'@'localhost' identified by 'ZD7NiwXQ';
# grant all on avtonew.* to 'avtonew'@'localhost';
# use avtonew;
# source avtonew.sql;
# exit

### cp -r /var/lib/mysql /var/www/html/tmp # not copy all
### mysqldump -p48115 --all-databases > all.sql # new copy
# ~~~ new only my db ~~~
### mysqldump -p48115 avtonew < avtonew.sql
## mysqldump -p48115 avtonew > avtonew.sql

# service php7.0-fpm restart