# Terraform Drift Management Demo
Terraform Drift Detection in Action: A Practical Guide
<p align="right"><em>By Zibusiso Edwin Ndlovu | DevOps Engineer | April 2025</em></p>
In the world of Infrastructure as Code (IaC), keeping your cloud infrastructure in sync with your Terraform configurations is crucial. However, manual changes (intentional or accidental) can happen, leading to what we call drift.

🚀 Setting Up the Example: Launch an EC2 Instance
Here's the Terraform code we'll use:
```sh
resource "aws_instance" "ubuntu_vm" {
  ami                    = var.ubuntu_ami_id
  key_name               = "deployer-key"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg_ssh.id]
  user_data              = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y apache2
              sed -i -e 's/80/8080/' /etc/apache2/ports.conf
              echo "Hello World. Terraform Drift Demo" > /var/www/html/index.html
              systemctl restart apache2
              EOF

  tags = {
    Name          = "terraform-drift-state-ec2"
    drift_example = "v1"
  }
}

resource "aws_security_group" "sg_ssh" {
  name = "sg_ssh"
  
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



```

✅ What this does:

Launches an Ubuntu EC2 instance with Apache installed.

Changes Apache to listen on port 8080 instead of the default 80.

Assigns custom tags, including drift_example = "v1".

Opens port 22 (SSH) so you can manually connect and introduce drift later.

Step 2: Introduce Drift Manually

Go to the AWS Management Console.

Navigate to your EC2 instance.

Modify something outside of Terraform — for example:

Change the instance type from t2.micro to t2.small.

Edit the tags (e.g., change drift_example from "v1" to "v2").

Modify the security group rules manually.

Important: This change is invisible to Terraform unless you re-scan!

🛠️ Step-by-Step: Simulating and Detecting Drift
Step 1: Deploy the Infrastructure

bash
Copy
Edit
terraform init
terraform apply
Terraform provisions your EC2 instance exactly as described in the code.

Step 2: Introduce Drift Manually

Go to the AWS Management Console.

Navigate to your EC2 instance.

Modify something outside of Terraform — for example:

Change the instance type from t2.micro to t2.small.

Edit the tags (e.g., change drift_example from "v1" to "v2").

Modify the security group rules manually.

Important: This change is invisible to Terraform unless you re-scan!

Step 3: Detect Drift with Terraform

Now, run:

bash
Copy
Edit
terraform plan
Terraform will output something like:

bash
Copy
Edit
~ aws_instance.ubuntu_vm
      instance_type: "t2.micro" => "t2.small"
      tags.drift_example: "v1" => "v2"
✅ This shows Terraform detecting drift — changes that exist in AWS but not in your Terraform configuration.

📈 Why Drift Detection


📈 Why Drift Detection Matters
Security Risks: Unauthorized changes (e.g., opening security groups to the world) could go unnoticed.

Compliance: Drifted resources may not comply with corporate policies.

Cost Control: Someone might accidentally upgrade instance types or enable expensive services.

Consistency: Automated deployments only work if the actual infrastructure matches your code.

🧠 Best Practices to Avoid and Manage Drift
Run terraform plan frequently, even outside deployments.

Use CI/CD pipelines that automatically check infrastructure state against Terraform code.

Implement restricted IAM permissions — prevent manual modifications unless necessary.

Periodically audit resources manually and with Terraform.

Use drift detection tools like:

terraform plan

terraform state list

Third-party tools: Atlantis, Spacelift, Scalr


In this post, we'll explore Terraform Drift Detection by deploying a simple AWS EC2 instance and then introducing drift manually to observe how Terraform identifies it.

Create infrastructure
Start by cloning the example repository. This configuration builds an EC2 instance, an SSH key pair, and a security group rule to allow SSH access to the instance.

$ git clone https://github.com/hashicorp-education/learn-terraform-drift-management

Change into the repository directory.

$ cd learn-terraform-drift-management

Create an SSH key pair in your current directory, replacing your_email@example.com with your email address. Use an empty passphrase.

$ ssh-keygen -t rsa -C "your_email@example.com" -f ./key
Generating public/private rsa key pair.

Enter passphrase (empty for no passphrase):

Confirm your AWS CLI region.

$ aws configure get region
us-east-2

Open the terraform.tfvars file and edit the region to match your AWS CLI configuration.

region = "us-east-2"

Open the main.tf file and review your configuration. The main resources are your EC2 instance, your key pair, and the SSH security group.

##...
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("${path.module}/key.pub")
}

resource "aws_instance" "example" {
  ami                    = data.aws_ami.ubuntu.id
  key_name               = aws_key_pair.deployer.key_name
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg_ssh.id]
  user_data              = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y apache2
              sed -i -e 's/80/8080/' /etc/apache2/ports.conf
              echo "Hello World" > /var/www/html/index.html
              systemctl restart apache2
              EOF
  tags = {
    Name          = "terraform-learn-state-ec2"
    drift_example = "v1"
  }
}


resource "aws_security_group" "sg_ssh" {
  name = "sg_ssh"
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  // connectivity to ubuntu mirrors is required to run `apt-get update` and `apt-get install apache2`
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

Initialize your configuration.

$ terraform init

Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Installing hashicorp/aws v3.26.0...
- Installed hashicorp/aws v3.26.0 (signed by HashiCorp)

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

Apply your configuration. Enter yes when prompted to accept your changes.

$ terraform apply


## ...

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

instance_id = "i-0250e3c625858c3ee"
public_ip = "18.224.17.153"
security_groups = [
  toset([
    "sg-0bf5fe7b3b54df9c3",
  ]),
]

When your apply operation completes, run terraform state list to review the resources managed by Terraform in your state file.

$ terraform state list
data.aws_ami.ubuntu
aws_instance.example
aws_key_pair.deployer
aws_security_group.sg_ssh

Introduce drift
To introduce a change to your configuration outside the Terraform workflow, create a new security group with the AWS CLI and export that value as an environment variable.


Mac or Linux

PowerShell
$  export SG_ID=$(aws ec2 create-security-group --group-name "sg_web" --description "allow 8080" --output text)

Confirm you created the environment variable. This will return the security group you just created.

$ echo $SG_ID
sg-04c74100cc8b9fc8c

Next, create a new rule for your group to provide TCP access to the instance on port 8080.

$ aws ec2 authorize-security-group-ingress --group-name "sg_web" --protocol tcp --port 8080 --cidr 0.0.0.0/0

Associate the security group you created manually with the EC2 instance provisioned by Terraform.

$ aws ec2 modify-instance-attribute --instance-id $(terraform output -raw instance_id) --groups $SG_ID

Now, you have replaced your instance's SSH security group with a new security group that is not tracked in the Terraform state file.

Run a refresh-only plan
By default, Terraform compares your state file to real infrastructure whenever you invoke terraform plan or terraform apply. The refresh updates your state file in-memory to reflect the actual configuration of your infrastructure. This ensures that Terraform determines the correct changes to make to your resources.

If you suspect that your infrastructure configuration changed outside of the Terraform workflow, you can use a -refresh-only flag to inspect what the changes to your state file would be. This is safer than the refresh subcommand, which automatically overwrites your state file without displaying the updates.

terraform refresh command
The terraform refresh command reads the current settings from all managed remote objects and updates the Terraform state to match. This command is deprecated. Instead, add the -refresh-only flag to terraform apply and terraform plan commands.

This does not modify your real remote objects, but it modifies the Terraform state.

Hands-on: Try the Use Refresh-Only Mode to Sync Terraform State tutorial.

Usage
Usage: terraform refresh [options]

This command is effectively an alias for the following command:

terraform apply -refresh-only -auto-approve

Consequently, it supports all of the same options as terraform apply except that it does not accept a saved plan file, it doesn't allow selecting a planning mode other than "refresh only", and -auto-approve is always enabled.

Automatically applying the effect of a refresh is risky. If you have misconfigured credentials for one or more providers, Terraform may be misled into thinking that all of the managed objects have been deleted, causing it to remove all of the tracked objects without any confirmation prompt.

Tip

The -refresh-only flag was introduced in Terraform 0.15.4, and is preferred over the terraform refresh subcommand.

Run terraform plan -refresh-only to determine the drift between your current state file and actual configuration.

$ terraform plan -refresh-only
aws_key_pair.deployer: Refreshing state... [id=deployer-key]
aws_security_group.sg_ssh: Refreshing state... [id=sg-0b318a348a4a4e391]
aws_instance.example: Refreshing state... [id=i-008bef01721ee7f7c]

Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the last "terraform apply":

  # aws_instance.example has been changed
  ~ resource "aws_instance" "example" {
        id                           = "i-008bef01721ee7f7c"
        tags                         = {
            "Name"          = "terraform-learn-state-ec2"
            "drift_example" = "v1"
        }
      ~ vpc_security_group_ids       = [
          + "sg-0226a51361bf1497a",
          - "sg-0b318a348a4a4e391",
        ]
        # (27 unchanged attributes hidden)




        # (4 unchanged blocks hidden)
    }

This is a refresh-only plan, so Terraform will not take any actions to undo
these. If you were expecting these changes then you can apply this plan to
record the updated values in the Terraform state without changing any remote
objects.

────────────────────────────────────────────────────────────────────────────────────

Changes to Outputs:
  ~ security_groups = [
      - [
          - "sg-0b318a348a4a4e391",
        ],
      + [
          + "sg-0226a51361bf1497a",
        ],
    ]

You can apply this plan to save these new output values to the Terraform state,
without changing any real infrastructure.

─────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.

As shown in the output, Terraform has detected differences between the infrastructure and the current state, and sees that your original security group allowing access on port 22 is no longer attached to your EC2 instance. The refresh-only plan output indicates that Terraform will update your state file to modify the configuration of your EC2 instance to reflect the new security group with access on port 8080.

Apply these changes to make your state file match your real infrastructure, but not your Terraform configuration. Respond to the prompt with a yes.

$ terraform apply -refresh-only
aws_key_pair.deployer: Refreshing state... [id=deployer-key-rita]
aws_security_group.sg_ssh: Refreshing state... [id=sg-0b318a348a4a4e391]
aws_instance.example: Refreshing state... [id=i-008bef01721ee7f7c]

Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the last "terraform apply":

  # aws_instance.example has been changed
##...
Would you like to update the Terraform state to reflect these detected changes?
  Terraform will write these changes to the state without modifying any real infrastructure.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes


Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

instance_id = "i-008bef01721ee7f7c"
public_ip = "35.163.80.243"
security_groups = [
  toset([
    "sg-0226a51361bf1497a",
  ]),
]

A refresh-only operation does not attempt to modify your infrastructure to match your Terraform configuration -- it only gives you the option to review and track the drift in your state file.

If you ran terraform plan or terraform apply without the -refresh-only flag now, Terraform would attempt to revert your manual changes. Instead, you will update your configuration to associate your EC2 instance with both security groups.

Add the security group to configuration
Import the sg_web security group resource to your state file to bring it under Terraform management.

First, add the resource definition to your configuration by adding a new security group resource and rule resource to your main.tf file.

resource "aws_security_group" "sg_web" {
  name        = "sg_web"
  description = "allow 8080"
}

resource "aws_security_group_rule" "sg_web" {
  type      = "ingress"
  to_port   = "8080"
  from_port = "8080"
  protocol  = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_web.id
}

Add the security group ID to your instance resource.

resource "aws_instance" "example" {
  ami                    = data.aws_ami.ubuntu.id
  key_name               = aws_key_pair.deployer.key_name
  instance_type          = "t2.micro"
 vpc_security_group_ids = [aws_security_group.sg_ssh.id]
 vpc_security_group_ids = [aws_security_group.sg_ssh.id, aws_security_group.sg_web.id]
  user_data              = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y apache2
              sed -i -e 's/80/8080/' /etc/apache2/ports.conf
              echo "Hello World" > /var/www/html/index.html
              systemctl restart apache2
              EOF
  tags = {
    Name          = "terraform-learn-state-ec2"
    drift_example = "v1"
  }
}

Import the security group
Tip

This tutorial uses terraform import to bring infrastructure under Terraform management. Terraform 1.5+ supports configuration-driven import, which lets you import multiple resources at once, review the import in your plan-and-apply workflow, and generate configuration for imported resources. Review the import tutorial to learn more.

Run terraform import to associate your resource definition with the security group created in the AWS CLI.

$ terraform import aws_security_group.sg_web $SG_ID

aws_security_group.sg_web: Importing from ID "sg-04c74100cc8b9fc8c"...
aws_security_group.sg_web: Import prepared!
  Prepared aws_security_group for import
aws_security_group.sg_web: Refreshing state... [id=sg-04c74100cc8b9fc8c]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.

Import your security group rule.

$ terraform import aws_security_group_rule.sg_web "$SG_ID"_ingress_tcp_8080_8080_0.0.0.0/0

aws_security_group_rule.sg_web: Importing from ID "sg-04c74100cc8b9fc8c_ingress_tcp_8080_8080_0.0.0.0/0"...
aws_security_group_rule.sg_web: Import prepared!
  Prepared aws_security_group_rule for import
aws_security_group_rule.sg_web: Refreshing state... [id=sg-04c74100cc8b9fc8c_ingress_tcp_8080_8080_0.0.0.0/0]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.

Run terraform state list to return the list of resources Terraform is managing, which now includes the imported resources.

$ terraform state list

data.aws_ami.ubuntu
aws_instance.example
aws_key_pair.deployer
aws_security_group.sg_web
aws_security_group.sg_ssh
aws_security_group_rule.sg_web

Terraform successfully associated both security groups with the instance in state. However, your instance still only allows port 8080 access because the modify-instance-attribute AWS CLI command detached the SSH security group.

Update your resources
Now that the sg_web security group is represented in state, re-run terraform apply to associate the SSH security group with your EC2 instance.

Notice how this updates your EC2 instance's security group to include both the security groups allowing SSH and 8080. Enter yes when prompted to confirm your changes.

$ terraform apply
aws_security_group.sg_ssh: Refreshing state... [id=sg-09d0b575577f258d5]
aws_key_pair.deployer: Refreshing state... [id=deployer-key]
aws_security_group.sg_web: Refreshing state... [id=sg-0acc6237c67c07e4b]
aws_security_group_rule.sg_web: Refreshing state... [id=sgrule-4278118923]
aws_instance.example: Refreshing state... [id=i-092c09eed28bdb2f7]

Terraform used the selected providers to generate the following execution plan. Resource actions
are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.example will be updated in-place
  ~ resource "aws_instance" "example" {
        id                           = "i-092c09eed28bdb2f7"
        tags                         = {
            "Name"          = "terraform-learn-state-ec2"
            "drift_example" = "v1"
        }
      ~ vpc_security_group_ids       = [
          + "sg-09d0b575577f258d5",
            # (1 unchanged element hidden)
        ]
        # (27 unchanged attributes hidden)




        # (4 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
##...

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.

Outputs:

instance_id = "i-092c09eed28bdb2f7"
public_ip = "3.142.238.150"
security_groups = [
  toset([
    "sg-09d0b575577f258d5",
    "sg-0acc6237c67c07e4b",
  ]),
]

Access the instance
Confirm your instance allows SSH. Enter yes when prompted to connect to the instance.

$ ssh ubuntu@$(terraform output -raw public_ip) -i key
The authenticity of host '3.142.238.150 (3.142.238.150)' can't be established.
ECDSA key fingerprint is SHA256:7PCkol+dVFps8YkOPMVZ7zG9sKXq0tnzqRENB7FTodM.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '3.142.238.150' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 20.04.2 LTS (GNU/Linux 5.4.0-1041-aws x86_64)
##...
ubuntu@ip-172-31-20-193:~$

Exit the SSH connection by typing exit in the SSH prompt.

Confirm your instance allows port 8080 access.

$ curl $(terraform output -raw public_ip):8080
Hello, World

Clean up your resources
When you are finished with this tutorial, destroy the resources you created. Enter yes when prompted to confirm your changes.

$ terraform destroy
##...
Destroy complete! Resources: 5 destroyed.


References:
https://developer.hashicorp.com/terraform/cli/commands/refresh

