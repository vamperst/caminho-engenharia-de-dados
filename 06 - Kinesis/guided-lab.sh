source ~/venv/bin/activate

pip3 install boto3

cd ~/environment/caminho-engenharia-de-dados

git pull origin master

cd 06-Kinesis

c9 open guided-lab.sh


aws cloudformation create-stack --stack-name kinesis-lab --parameters  ParameterKey=email,ParameterValue=rafael@rfbarbosa.com ParameterKey=SMS,ParameterValue=+5511997649185 ParameterKey=Username,ParameterValue=admin ParameterKey=Password,ParameterValue=fiap123456 --template-body file://kinesis-lab.json --capabilities CAPABILITY_IAM

Confirmar subscrição no email

Entrar no KDG pelos aoutputs do cloudformation e utlizar usuario e senha 

---Templates:
Schema Discovery Payload

{"browseraction":"DiscoveryKinesisTest", "site": "yourwebsiteurl.domain.com"}

Click Payload

{"browseraction":"Click", "site": "yourwebsiteurl.domain.com"}

Impression Payload

{"browseraction":"Impression", "site": "yourwebsiteurl.domain.com"}

Criar aplicação data-analytics nomeada: anomaly-detection-application
utilizar {stack-name}-FirehoseDeliveryStream-{some-random-string} como fonte
Escolher a IAM {stack-name}-CSEKinesisAnalyticsRole-{random string}

IR ao KDG em outra aba e ligar o Schema discovery Payload

Volte a aba do kinesis e clique em discovery schema

Salve e continue

Na aba da aplicação criada, clique em `SQL editor` e aceite


Copie o conteudo do arquivo anomaly_detection.sql no espaço para queries

Clique em Save and Run SQL


Conectar o lambda como destino.sql

Abrir 3 abas de click payload a 1 a cada 1 segundo, uma de impressão a 1 a cada 1 segundo, e uma aba com click payload 10 a cada 1 segundo.sql

Receber os emails
