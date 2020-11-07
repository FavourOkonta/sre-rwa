#! /bin/bash
sudo yum update -y
sudo yum install mysql python3 -y
mysql -u favour -p crossover -h mysql.cpwsyhaumzrv.us-east-1.rds.amazonaws.com < hello_world.sql
cd app/config
vim prod.cfg
cd ..
python3 -m venv venv
. venv/bin/activate
pip install Flask
pip install mysql-connector-python
python3 index.py