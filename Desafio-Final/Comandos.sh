aws dynamodb create-table \
    --table-name susep-sinistro-2 \
    --attribute-definitions AttributeName=id,AttributeType=S \
    --key-schema AttributeName=id,KeyType=HASH \
    --billing-mode PROVISIONED \
    --stream-specification StreamEnabled=true,StreamViewType=NEW_IMAGE \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5



aws dynamodb update-table \
    --table-name susep-sinistro \
    --billing-mode PROVISIONED \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=1500


wget https://github.com/prasmussen/gdrive/releases/download/2.1.1/gdrive_2.1.1_linux_386.tar.gz
tar xvzf gdrive_2.1.1_linux_386.tar.gz
chmod +x gdrive
./gdrive download 1EkzziJA6uWeuerhyugzw5ziBMYHsLfxq