#!/bin/bash
. $(dirname ${BASH_SOURCE})/util.sh


backtotop
desc 'Deploy Mysql database for catalog data'
runc 'oc new-app mysql -e MYSQL_ROOT_PASSWORD=password'

backtotop
desc 'Lets see if mysql is ready'
runc 'oc get pods'
runc 'kubectl get pods'


backtotop
desc 'Deploy Store Front End'
runc 'oc new-app https://github.com/debianmaster/store-frontend --name=store --strategy=source -l version=v1'


backtotop
desc 'Connect Store frontend with inventory and products api'
runc 'oc env dc store inventory_svc=http://inventory:8000 products_svc=http://products:8080'


backtotop
desc 'Deploy products mongod database'
runc 'oc new-app mongodb -l app=mongodb --name=productsdb \
  -e MONGODB_ADMIN_PASSWORD=password  -e MONGODB_USER=app_user \
  -e MONGODB_DATABASE=store  -e MONGODB_PASSWORD=password'
  
backtotop
desc 'Deploy products nodejs api'
runc 'oc new-app https://github.com/debianmaster/store-products.git --name=products -l version=v1'

backtotop
desc 'Connect products api with mongodb'
runc "oc env dc products MONGO_USER=app_user MONGO_PASSWORD=password \
 MONGO_SERVER=productsdb MONGO_PORT=27017 MONGO_DB=store \
 mongo_url='mongodb://app_user:password@productsdb/store'"


backtotop
desc 'Get mysql container name'
runc 'export MYSQL=$(oc get pods -l app=mysql -o jsonpath={.items[0].metadata.name})'

backtotop
desc 'From inventory directory create catalog data by Copying'
runc 'cd ~/store-inventory'
runc 'oc cp ./script.sql $MYSQL:/tmp/script.sql'

backtotop
desc 'Import catalog data into mysql'
desc 'mysql -h 127.0.0.1 -u root -p < /tmp/script.sql'
runc 'oc rsh $MYSQL'

backtotop
desc 'deploy inventory service and connect database'
runc 'oc new-app https://github.com/i63/store-inventory strategy=docker --name=inventory -l version=v1'
runc 'oc logs -f inventory-1-build'

backtotop
runc 'oc env dc inventory sql_db=store sql_host=mysql sql_user=root sql_password=password'




