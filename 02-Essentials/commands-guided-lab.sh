aws iam create-role --role-name role-ec2-s3 --assume-role-policy-document file://trust-policy.json

aws iam create-policy --policy-name policy-ec2-s3 --policy-document file://policy-s3.json

aws iam attach-role-policy --policy-arn arn:aws:iam::624732922460:policy/policy-ec2-s3 --role-name role-ec2-s3

aws iam create-instance-profile --instance-profile-name instance-profile-ec2-s3

aws iam add-role-to-instance-profile --instance-profile-name instance-profile-ec2-s3 --role-name role-ec2-s3

aws --region us-east-1 ec2 \
 create-key-pair \
 --key-name "guided-lab" \
 | \
 jq -r ".KeyMaterial" > ~/.ssh/guided-lab.pem   

 chmod 400 ~/.ssh/fiap-lab.pem

aws ec2 run-instances --image-id ami-8c1be5f6 --count 1 --instance-type t2.micro --key-name guided-lab --iam-instance-profile Name="instance-profile-ec2-s3"