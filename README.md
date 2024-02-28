# READ ME

Simple VPC with NAT instances.

```bash
./bootstrap-remote-state-bucket.sh
terraform init
terraform plan \
    -var=prefix=<your-vpc-prefix> \
    -var=ssh_key_name=<your-ec2-ssh-key-name> \
    -var=public_access_allow_list='["1.2.3.4/32"]' \
    -out plan.tfplan
terraform apply plan.tfplan
```
