curl https://perso.telecom-paristech.fr/eagan/class/igr204/data/cereal.csv -o cereal.csv 
curl https://perso.telecom-paristech.fr/eagan/class/igr204/data/cars.csv -o car.csv
curl https://perso.telecom-paristech.fr/eagan/class/igr204/data/factbook.csv -o factbook.csv



aws s3api create-bucket --bucket teste-storage-random --region us-east-1


aws s3 cp car.csv s3://teste-storage-random/car/car.csv

aws s3 cp cereal.csv s3://teste-storage-random/cereal/cereal.csv

aws s3 cp factbook.csv s3://teste-storage-random/factbook/factbook.csv

aws s3 cp factbook.csv s3://teste-storage-random/other/factbook.tst

cd lambda

npm install serverless-pseudo-parameters

sls deploy

sls invoke --function getObject --stage dev --region us-east-1 --path event.json --log


