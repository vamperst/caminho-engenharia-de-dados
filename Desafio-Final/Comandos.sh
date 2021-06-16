aws dynamodb create-table \
    --table-name susep-sinistro \
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

export outputPolicy=$(aws iam create-policy --policy-name policy-firehose-susep --policy-document file://file1.json)
export policyArn=$(echo $outputPolicy | jq .Policy.Arn | sed 's/"//g')
aws iam create-role --role-name role-firehose-susep --assume-role-policy-document file://trust-policy.json
aws iam attach-role-policy --policy-arn $policyArn --role-name role-firehose-susep
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AdministratorAccess --role-name role-firehose-susep
export roleARN=$(aws iam get-role --role-name role-firehose-susep | jq .Role.Arn)


sed -i "s/NOMEBUCKET/$nomeBucket/g" test.txt
sed -i "s/ROLEFIREHOSEARN/$roleARN/g" test.txt
echo $(python -c "import sys;lines=sys.stdin.read();print(lines.replace('ROLEFIREHOSEARN',$(echo $roleARN)))" < test.txt) | jq >> test2.txt


aws firehose create-delivery-stream --cli-input-json file://test2.txt

