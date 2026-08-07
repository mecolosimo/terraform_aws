# Bastion Host and Private Instance

## Setup

Copy the `terraform.tfvars.example` file to `terraform.tfvars` and update the variables.

```bash
terraform init
# terraform init -upgrade # if we changed things
terraform import aws_instance.bastion <instance-id>
terraform validate
terraform plan
terraform apply

# Remove the bastion instance from Terraform state (it doesn't delete it from AWS)
terraform state rm aws_instance.bastion
# Destroy everything else
terraform destroy
# Re-import the bastion instance back into state
terraform import aws_instance.bastion <instance-id>
```

Running the Terraform `import` command brings the existing infrastructure under Terraform management without recreating. In *bastion.tf* it prevents Terraform from accidentally destroying it as well.

### Subnets

This is the hardest part, for me.

CIDR addressing can be confusing: see [cidrsubnet](https://developer.hashicorp.com/terraform/language/functions/cidrsubnet).

Say our VPC's CIDR is `172.31.0.0/16`. Using *ipcalc* gives:

```bash
Address:   172.31.0.0           10101100.00011111. 00000000.00000000
Netmask:   255.255.0.0 = 16     11111111.11111111. 00000000.00000000
Wildcard:  0.0.255.255          00000000.00000000. 11111111.11111111
=>
Network:   172.31.0.0/16        10101100.00011111. 00000000.00000000
HostMin:   172.31.0.1           10101100.00011111. 00000000.00000001
HostMax:   172.31.255.254       10101100.00011111. 11111111.11111110
Broadcast: 172.31.255.255       10101100.00011111. 11111111.11111111
Hosts/Net: 65534                 Class B, Private Internet
```

Say AWS made for use a Public Subnet for our *terraform/bastion* host
`172.31.16.0/20`. Now we want our Private Subnet at `172.31.32.0/20`.
*ipcalc* gives:

```bash
Address:   172.31.32.0          10101100.00011111.0010 0000.00000000
Netmask:   255.255.240.0 = 20   11111111.11111111.1111 0000.00000000
Wildcard:  0.0.15.255           00000000.00000000.0000 1111.11111111
=>
Network:   172.31.32.0/20       10101100.00011111.0010 0000.00000000
HostMin:   172.31.32.1          10101100.00011111.0010 0000.00000001
HostMax:   172.31.47.254        10101100.00011111.0010 1111.11111110
Broadcast: 172.31.47.255        10101100.00011111.0010 1111.11111111
Hosts/Net: 4094                  Class B, Private Internet
```

We'll use `cidrsubnet(prefix, newbits, netnum)` like this
`cidrsubnet(data.aws_vpc.existing_vpc.cidr_block, 8, 32)`:

```text
172.       31.        ?          0
10101100 | 00011111 | XXXXXXXX | 00000000
parent network      |  netnum  | host
```
`newbits = 8` means add 8 more bits for subnetting. The new prefix length
is: 20 + 8 = /28. Each subnet is a /28 with 16 IP addresses each 
\(2^\(32-28\)\). `netnum = 32` means we're calculating the 32nd subnet, which is represented in binary as 00100000, allowing us to fill in the
XXXXXXXX segment in the above:

```text
172.       31.        32.          0
10101100 | 00011111 | 00100000 | 00000000
parent network      |  netnum  | host
```

Ideally, we would use this. But I could figure out how to make it work with
differn VPC CIRDs. So you'll have to pick a private subnet CIRD to use that isn't being use or overlaps with anything else.

## SSH

To get to the worker

```bash
ssh -F local/ssh.cfg worker
```

The -F flag in SSH specifies an alternative per-user configuration file to use instead of the default file.

Terraform makes an RSA key-pair placing the public part on the server
\(worker\), the private part under *local* and configures the ssh config to use that as identity.
