aws dynamodb create-table \
    --table-name susep-sinistro \
    --attribute-definitions AttributeName=id,AttributeType=S \
    --key-schema AttributeName=id,KeyType=HASH \
    --billing-mode PROVISIONED
    --stream-specification StreamEnabled=true,StreamViewType=NEW_IMAGE \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5