source ~/venv/bin/activate

pip3 install boto3

cd ~/environment/caminho-engenharia-de-dados

git pull origin master

cd 07-KinesisDataStream-Glue-Athena

c9 open guided-lab.sh

Criar um kinesis data stream com 2 shards, nomeado TicketTransactionStreamingData

Navegue até o Menu do Glue e adicione uma table manualmente chamada TicketTransactionStreamData
A database se chamará tickettransactiondatabase
Selecione o stream kinesis TicketTransactionStreamingData como fonte
Formato json
Esquema vazio
Crie


Navegue até o painel do GLue para criar um trabalho streaming chamado TicketTransactionStreamingJob
Spark streaming proposto pelo Glue
Criar uma Role para o Glue
Data target = Amazon S3, Parquet com caminho no bucket terminando em /TicketTransactionStreamData
Automaticamente detect schema of each record
Rode o job


No KDG crie um template chamado NormalTransaction com o seguinte conteudo:
{
    "customerId": "{{random.number(50)}}",
    "transactionAmount": {{random.number(
        {
            "min":10,
            "max":150
        }
    )}},
    "sourceIp" : "{{internet.ip}}",
    "status": "{{random.weightedArrayElement({
        "weights" : [0.8,0.1,0.1],
        "data": ["OK","FAIL","PENDING"]
        }        
    )}}",
   "transactionTime": "{{date.now}}"      
}


E comece a enviar para o kinesis stream 100 por segundo
Após alguns minutos verique a pasta onde pediu para enviar os resultados do Glue job


Criar o Crawler 

Selecione Crawler no menu lateral do Glue e adiocione um crawler chamado TicketTransactionParquetDataCrawler
Utilize o S3 e pasta configurados no passo do trabalho
Exclua o checkpoint/**
Colque para rodar de hora em hora
No output coloque o prefixo da table como parquet_
Salve e execute o Crawler

Em outra aba do KDG crie um template chamado AbnormalTransaction com o seguinte conteudo:
{
    "customerId": "{{random.number(50)}}",
    "transactionAmount": {{random.number(
        {
            "min":10,
            "max":150
        }
    )}},
    "sourceIp" : "221.233.116.256",
    "status": "{{random.weightedArrayElement({
        "weights" : [0.8,0.1,0.1],
        "data": ["OK","FAIL","PENDING"]
        }        
    )}}",
   "transactionTime": "{{date.now}}"      
}

Comece a enviar para o kinesis stream 1 por segundo

Fazendo querys no Athena
Configurar bucket das querys 
Aducionar partições

SELECT count(*) as numberOfTransactions, sourceip
FROM "tickettransactiondatabase"."parquet_tickettransactionstreamingdata" 
WHERE ingest_year='2021'
AND cast(ingest_year as bigint)=year(now())
AND cast(ingest_month as bigint)=month(now())
AND cast(ingest_day as bigint)=day_of_month(now())
AND cast(ingest_hour as bigint)=hour(now())
GROUP BY sourceip
Order by numberOfTransactions DESC;


SELECT *
FROM "tickettransactiondatabase"."parquet_tickettransactionstreamingdata" 
WHERE ingest_year='2021'
AND cast(ingest_year as bigint)=year(now())
AND cast(ingest_month as bigint)=month(now())
AND cast(ingest_day as bigint)=day_of_month(now())
AND cast(ingest_hour as bigint)=hour(now())
AND sourceip='221.233.116.256'
limit 100;


Exclua tudo:
Glue table
Glue job
Glue Crawler
Kinesis data Stream

aws s3 rm s3://Buckets-Outputs --recursive

aws cloudformation delete-stack --stack-name kinesis-lab

