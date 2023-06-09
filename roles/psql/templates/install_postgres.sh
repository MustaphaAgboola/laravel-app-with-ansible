#!/bin/bash

#script to install and set it up on ubuntu server

postgres_packages=('postgresql' 'postgresql-contrib')
password='{{ pgsql_login_password }}'
userpassword='{{ pgsql_user_password }}'
username='{{ pgsql_username }}'
dbname='{{ pgsql_db_name }}'
config='{{ pgsql_config }}'

echo 'running sudo apt update...'
sudo apt update

echo 'installing postgres packages from ubuntu repo'
sudo apt install ${postgres_packages[@]} -y

echo 'ensuring postgresql is active...'
sudo systemctl start postgresql

echo 'creating a new user...'
sudo -u postgres create user - '$username'

echo "creating a database for the user..."
sudo -u postgres createdb "$dbname" -O "$username"

echo "setting a password for "$username"..."
sudo -u postgres psql -c "ALTER USER "$username" WITH PASSWORD '${userpassword}';"

echo "setting a password for postgres user..."
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '${password}';"

echo "editing the config file to allow md5"
sudo gawk -i inplace '$2 ~ /all/ {gsub(/peer/, "md5")};{print}' "$config"

echo "restarting postgresql..."
sudo systemctl restart postgresql