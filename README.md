# Terraform AWS

Examples using [Terraform](https://developer.hashicorp.com/terraform/) to build AWS infrastructure. Also see [learn-slurm](https://github.com/parlaynu/learn-slurm). I used Google's "gemini" to VIBE code this \(maybe not best word for this\). I miss Claude Code, it was better IMHO. I tried to catch issues but my knowlegde of terraform and AWS is years out of date. So, I make no gaureente about the security and correctness of this code.

## Prerequisites

You need an AWS account with Administractor Access for this to work.

First, create an EC2 Instance and attach a policy to it \(see below\). The public subnet it is 
assigned, should only allow **trusted** networks to connect (*e.g.*, your home WAN address\).

You'll need the IDs of the VPC and Subnet \(click on the instance and it should display it\).

### Create the IAM Policy for Terraform

Login to the [AWS Management Console](https://aws.amazon.com/console/)

1. Open the IAM Console.
2. Click *Policies* in the left sidebar, then click *Create policy*.
3. Click Create and enter details/actions
    ```json
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "VisualEditor0",
                "Effect": "Allow",
                "Action": [
                    "s3:PutObject",
                    "s3:GetObject",
                    "iam:PassRole",
                    "ec2:AllocateAddress",
                    "ec2:AssociateRouteTable",
                    "ec2:AuthorizeSecurityGroupEgress",
                    "ec2:AuthorizeSecurityGroupIngress",
                    "ec2:CreateNatGateway",
                    "ec2:CreateRoute",
                    "ec2:CreateRouteTable",
                    "ec2:CreateSecurityGroup",
                    "ec2:CreateSubnet",
                    "ec2:CreateTags",
                    "ec2:DeleteKeyPair",
                    "ec2:DeleteNatGateway",
                    "ec2:DeleteSecurityGroup",
                    "ec2:DeleteSubnet",
                    "ec2:DeleteTags",
                    "ec2:DescribeAddresses",
                    "ec2:DescribeAddressesAttribute",
                    "ec2:DescribeInstances",
                    "ec2:DescribeInstanceAttribute",
                    "ec2:DescribeInstanceCreditSpecifications",
                    "ec2:DescribeInstanceTypes",
                    "ec2:DescribeImages",
                    "ec2:DescribeKeyPairs",
                    "ec2:DescribeNatGateways",
                    "ec2:DescribeNetworkInterfaces",
                    "ec2:DescribeRouteTables",
                    "ec2:DescribeSecurityGroups",
                    "ec2:DescribeSubnets",
                    "ec2:DescribeVolumes",
                    "ec2:DescribeVpcs",
                    "ec2:DescribeVpcAttribute",
                    "ec2:DescribeTags",
                    "ec2:ImportKeyPair",
                    "ec2:ReleaseAddress",
                    "ec2:RevokeSecurityGroupEgress",
                    "ec2:RunInstances",
                    "ec2:TerminateInstances",
                    "s3:CreateBucket",
                    "s3:ListBucket",
                    "s3:DeleteObject"
                ],
                "Resource": "*"
            }
        ]
    }
    ```
4. Click Next, name your policy \(*e.g.*, `terraform-policy`\), and click Create policy.

This is what is need by terraform, it seems like a lot and is. I think some things it need for setting 
up to do stuff. You can always remove the policy from the instance when done.

####  Create the IAM Role for EC2

The AWS Console automatically creates the required Instance Profile behind the scenes when you build a role this way.

1. In the IAM Console, click Roles in the left sidebar, then click Create role.
2. Select *AWS service* as the trusted entity type.
3. Select EC2 from the "Service or use case" dropdown. Click Next.
4. In the permissions list, search for the policy you made above. Check the box next to it. Click Next.
5. Give the role a name \(*e.g.*, `terraform-role`\) and click Create role

#### SSL Key

If you already have a KEY pair you can use that, if not go to AWS EC2 console, click *Key Pairs* in the left sidebar and get a new Key \(use PEM format\) and save it under
`~/.ssh/`. Change the mode of the file \(*e.g.*, `chmod 400 your-key.pem`\).

#### Launch Instance

1. In the EC2 Console, click Instance in the left sidebar, then click *Launch Instance*.
2. Select the type you want, it does not need to be large.
3. Select you key pair (login) to use.
4. Under *Network settings*, Allow SSH traffic from select My IP \(should be WAN, not your machine's IP\)
5. Under *Advance* details, select the profile from above under the IAM instance profile dropdown.
   - You can also add it after creating it by selecting the instance and selecting **Actions** --> **Security**
6. Launch Instance and click on *instance ID*.
7. Login \(*e.g.*, `ssh -i ~/.ssh/your-key.pem ec2-user@your-instance-public-ip`\).

#### Terraform

[Install](https://developer.hashicorp.com/terraform/install) Terraform on you new instance.
**WARNING** if using package manager, Amazon Linux is not the same as RedHat \(select the matching one\).

#### AWS Command Line Interface

Install the AWS [cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
This can be tricky. Make sure your it is configured \(seach for IAM Idenity Center and the right show have links\).
Next configure [cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html) access. Even as a
`root` user you need to add a user \(*e.g.*, admin-sso\) and under  *Permission sets* add  **AdministratorAccess**
to this new user. Next select *AWS accounts* and select the user to add the new permission sets.

### Create the IAM Policy for S3

Repeat the steps above for making a role but name it *s3-rw-role*  with actions
`s3:PutObject, GetObject, DeleteObject, CreateBucket, ListBucket`. This will be applied to
the newly create instances by Terraform.
