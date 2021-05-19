source ~/venv/bin/activate

pip3 install boto3

cd ~/environment/caminho-engenharia-de-dados

git pull origin master

cd 05-Dynamo-Advanced

npm install -g c9

c9 open guided-lab.sh

#listar itens da pasta atual
ls -l .

#Listar itens da pasta data
ls -l ./data

#Ver inicio do arquivo de logs
head -n1 ./data/logfile_small1.csv

#Ver inicio do arquivo de empregados
head -n1 ./data/employees.csv


#criar e esperar a table ficar pronta
aws dynamodb create-table --table-name logfile_scan \
--attribute-definitions AttributeName=PK,AttributeType=S AttributeName=GSI_1_PK,AttributeType=S AttributeName=GSI_1_SK,AttributeType=S \
--key-schema AttributeName=PK,KeyType=HASH \
--billing-mode PAY_PER_REQUEST \
--tags Key=workshop-design-patterns,Value=targeted-for-cleanup \
--global-secondary-indexes "IndexName=GSI_1,\
KeySchema=[{AttributeName=GSI_1_PK,KeyType=HASH},{AttributeName=GSI_1_SK,KeyType=RANGE}],\
Projection={ProjectionType=KEYS_ONLY}"

aws dynamodb wait table-exists --table-name logfile_scan

#populando a table para a parte de scan
nohup python3 load_logfile_parallel.py logfile_scan & disown

#verificar se o script esta rodando em background
pgrep -l python


#Criar table log file e esperar
aws dynamodb create-table --table-name logfile \
--attribute-definitions AttributeName=PK,AttributeType=S AttributeName=GSI_1_PK,AttributeType=S \
--key-schema AttributeName=PK,KeyType=HASH \
--provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
--tags Key=workshop-design-patterns,Value=targeted-for-cleanup \
--global-secondary-indexes "IndexName=GSI_1,\
KeySchema=[{AttributeName=GSI_1_PK,KeyType=HASH}],\
Projection={ProjectionType=INCLUDE,NonKeyAttributes=['bytessent']},\
ProvisionedThroughput={ReadCapacityUnits=5,WriteCapacityUnits=5}"

aws dynamodb wait table-exists --table-name logfile

#Verifica o estado da table criada
aws dynamodb describe-table --table-name logfile --query "Table.TableStatus"


#inserir dados na table
python3 load_logfile.py logfile ./data/logfile_small1.csv

#inserir dados na table
python3 load_logfile.py logfile ./data/logfile_medium1.csv


#Ver eventos de throttled na tabela do dynamoDB, GSI é consumido de maneira assincrona



#Aumentar a capacidade da table
aws dynamodb update-table --table-name logfile \
--provisioned-throughput ReadCapacityUnits=100,WriteCapacityUnits=100

time aws dynamodb wait table-exists --table-name logfile

#Colocar mais dados
python3 load_logfile.py logfile ./data/logfile_medium2.csv


#Criar outra table com o GSI com baixa capacidade
aws dynamodb create-table --table-name logfile_gsi_low \
--attribute-definitions AttributeName=PK,AttributeType=S AttributeName=GSI_1_PK,AttributeType=S \
--key-schema AttributeName=PK,KeyType=HASH \
--provisioned-throughput ReadCapacityUnits=1000,WriteCapacityUnits=1000 \
--tags Key=workshop-design-patterns,Value=targeted-for-cleanup \
--global-secondary-indexes "IndexName=GSI_1,\
KeySchema=[{AttributeName=GSI_1_PK,KeyType=HASH}],\
Projection={ProjectionType=INCLUDE,NonKeyAttributes=['bytessent']},\
ProvisionedThroughput={ReadCapacityUnits=1,WriteCapacityUnits=1}"


#Colocar dados na table e esperar erro
python3 load_logfile_parallel.py logfile_gsi_low

#digite ctrl+C para sair do erro


#abrir arquivo de scan sequencial e falar sobre limites do dynamoDB
c9 open scan_logfile_simple.py

python3 scan_logfile_simple.py logfile_scan

#abrir arquivo de scan paralelo
c9 open scan_logfile_parallel.py


python3 scan_logfile_parallel.py logfile_scan 2

python3 scan_logfile_parallel.py logfile_scan 5


#Descreva o GSI 
aws dynamodb describe-table --table-name logfile_scan --query "Table.GlobalSecondaryIndexes"

c9 open query_responsecode.py
#Utilizar um scan para procurar todos os logs com 404
python3 query_responsecode.py logfile_scan 404


#Utilizar um scan para procurar todos os logs com 404 em uma data
python3 query_responsecode.py logfile_scan 404 --date 2017-07-21


#criar table para ter sobrecarga de GSI
aws dynamodb create-table --table-name employees \
--attribute-definitions AttributeName=PK,AttributeType=S AttributeName=SK,AttributeType=S \
AttributeName=GSI_1_PK,AttributeType=S AttributeName=GSI_1_SK,AttributeType=S \
--key-schema AttributeName=PK,KeyType=HASH AttributeName=SK,KeyType=RANGE \
--provisioned-throughput ReadCapacityUnits=100,WriteCapacityUnits=100 \
--tags Key=workshop-design-patterns,Value=targeted-for-cleanup \
--global-secondary-indexes "IndexName=GSI_1,\
KeySchema=[{AttributeName=GSI_1_PK,KeyType=HASH},{AttributeName=GSI_1_SK,KeyType=RANGE}],\
Projection={ProjectionType=ALL},\
ProvisionedThroughput={ReadCapacityUnits=100,WriteCapacityUnits=100}"

#Coloque dados na table
python3 load_employees.py employees ./data/employees.csv


#Revisar a table no console e fazer scan pelo GSI


#

c9 open query_employees.py
python3 query_employees.py employees state 'WA'

python3 query_employees.py employees state 'TX'

python3 query_employees.py employees current_title 'Software Engineer'

python3 query_employees.py employees current_title 'IT Support Manager'

python query_employees.py employees name 'Dale Marlin'


#Adicionar outro GSI na table de empregados
aws dynamodb update-table --table-name employees \
--attribute-definitions AttributeName=GSI_2_PK,AttributeType=S AttributeName=GSI_2_SK,AttributeType=S \
--global-secondary-index-updates file://gsi_manager.json

#Verifique que ainda esta criando
aws dynamodb describe-table --table-name employees --query "Table.GlobalSecondaryIndexes[].IndexStatus"

#verifica a cada 2 segundos quando ambos estiverem ACITE pressione ctrl+C
watch -n 2 "aws dynamodb describe-table --table-name employees --query \"Table.GlobalSecondaryIndexes[].IndexStatus\""


#Fazer scan para achar todos os gerentes de 100 em 100
c9 open scan_for_managers.py


python3 scan_for_managers.py employees 100

# Fazer scan utilizando o GSI secundario que tem menos dados
c9 open scan_for_managers_gsi.py
python scan_for_managers_gsi.py employees 100


#Criar terceiro GSI
aws dynamodb update-table --table-name employees \
--attribute-definitions AttributeName=GSI_3_PK,AttributeType=S AttributeName=GSI_3_SK,AttributeType=S \
--global-secondary-index-updates file://gsi_city_dept.json

c9 open gsi_city_dept.json

#verifica a cada 2 segundos quando ambos estiverem ACITE pressione ctrl+C
watch -n 2 "aws dynamodb describe-table --table-name employees --query \"Table.GlobalSecondaryIndexes[].IndexStatus\""


#Após criar ir no painel e fazer query state#AZ e Phoenix#Develop


#Fazer pesquisa por estado no GSI3
c9 open query_city_dept.py
python3 query_city_dept.py employees TX

#Fazer pesquisa quem é de dallas
python3 query_city_dept.py employees TX --citydept Dallas

#Fazer pesquisa quem é de dallas e de operação
python query_city_dept.py employees TX --citydept 'Dallas#Op'


