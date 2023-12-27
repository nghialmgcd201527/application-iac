####################
#    Create VPC    #
####################
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"

  tags = {
    "Name"        = "${var.project_name}-${var.vpc_cidr}-vpc"
    "Environment" = var.environment
  }
}

####################
#      Subnets     #
####################
#

/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = "${var.environment}"
  }
}


/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  vpc        = true
  count      = length(var.private_subnets_cidr)
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.project_name}-${element(var.az_shortname, count.index)}-nat-eip"
  }
}

/* NAT */
resource "aws_nat_gateway" "nat_gateway" {
  count         = length(var.availability_zones)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = element(aws_subnet.public_subnet.*.id, count.index)
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name        = "${var.project_name}-Isolation-NATGW-${element(var.az_shortname, count.index)}"
    Environment = "${var.environment}"
    Tier        = "Private"
  }
}

/* Public subnet */
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.availability_zones)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-Public-${element(var.az_shortname, count.index)}"
    Environment = "${var.environment}"
    Tier        = "Public"
  }
}
/* Private subnet */
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.private_subnets_cidr)
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project_name}-Isolation-${element(var.az_shortname, count.index)}"
    Environment = "${var.environment}"
    Tier        = "Isolation"
  }
}



/* Datacenter subnet */
resource "aws_subnet" "datacenter_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.datacenter_subnets_cidr)
  cidr_block              = element(var.datacenter_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project_name}-Datacenter-${element(var.az_shortname, count.index)}"
    Environment = "${var.environment}"
    Tier        = "Datacenter"
  }
}

/* Datacenter subnet */
resource "aws_subnet" "thirdparty_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.thirdparty_subnets_cidr)
  cidr_block              = element(var.thirdparty_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project_name}-ThirdParty-${element(var.az_shortname, count.index)}"
    Environment = "${var.environment}"
    Tier        = "ThirdParty"
  }
}



/* Routing table for private subnet */
resource "aws_route_table" "private_subnet_rtb" {
  count  = length(var.private_subnets_cidr)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.project_name}-Isolation-${element(var.az_shortname, count.index)}"
    Environment = "${var.environment}"
  }
}

/* Routing table for public subnet */
resource "aws_route_table" "public_subnet_rtb" {
  count  = length(var.public_subnets_cidr)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.project_name}-Public-${element(var.az_shortname, count.index)}"
    Environment = "${var.environment}"
  }
}

/* Routing table for 3rdparty subnet */
resource "aws_route_table" "thirdparty_subnet_rtb" {
  count  = length(var.thirdparty_subnets_cidr)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.project_name}-ThirdParty-${element(var.az_shortname, count.index)}"
    Environment = "${var.environment}"
  }
}

/* Routing table for datacenter subnet */
resource "aws_route_table" "datacenter_subnet_rtb" {
  count  = length(var.datacenter_subnets_cidr)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.project_name}-Datacenter-${element(var.az_shortname, count.index)}"
    Environment = "${var.environment}"
  }
}




resource "aws_route" "igw" {
  count                  = length(var.public_subnets_cidr)
  route_table_id         = aws_route_table.public_subnet_rtb[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "nat_gw_iso" {
  count                  = length(var.private_subnets_cidr)
  route_table_id         = aws_route_table.private_subnet_rtb[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway[count.index].id
}

resource "aws_route" "nat_gw_Data" {
  count                  = length(var.datacenter_subnets_cidr)
  route_table_id         = aws_route_table.datacenter_subnet_rtb[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway[count.index].id
}

resource "aws_route" "nat_gw_thirdparty" {
  count                  = length(var.thirdparty_subnets_cidr)
  route_table_id         = aws_route_table.thirdparty_subnet_rtb[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway[count.index].id
}




/* Route table associations */
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_subnet_rtb[count.index].id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_subnet[0].id
  route_table_id = aws_route_table.private_subnet_rtb[0].id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_subnet[1].id
  route_table_id = aws_route_table.private_subnet_rtb[1].id
}


resource "aws_route_table_association" "datacenter" {
  count          = length(var.datacenter_subnets_cidr)
  subnet_id      = element(aws_subnet.datacenter_subnet.*.id, count.index)
  route_table_id = aws_route_table.datacenter_subnet_rtb[count.index].id
}

resource "aws_route_table_association" "thirdparty" {
  count          = length(var.thirdparty_subnets_cidr)
  subnet_id      = element(aws_subnet.thirdparty_subnet.*.id, count.index)
  route_table_id = aws_route_table.thirdparty_subnet_rtb[count.index].id
}






#####################################
# Create JumpBox in AZ A
#####################################
data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "SSM-role-attachment" {
  role       = aws_iam_role.SSM-role.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}

resource "aws_iam_role" "SSM-role" {
  name = "SSM-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "SSM-Role"
  role = aws_iam_role.SSM-role.name
}


resource "aws_instance" "jumpbox" {
  ami                         = var.ami
  availability_zone           = "ap-southeast-1a"
  ebs_optimized               = false
  instance_type               = "t3a.nano"
  monitoring                  = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  key_name                    = ""
  subnet_id                   = aws_subnet.public_subnet[0].id
  vpc_security_group_ids      = [aws_security_group.jumpbox_sg.id]
  associate_public_ip_address = true
  source_dest_check           = true

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = true
  }

  tags = {
    project = "${var.project_name}"
    Name    = "${var.stage}-Jumpbox-2A"
  }
}

######################################
##  VPC's Default Security Group
######################################

resource "aws_security_group" "private_vpc_sg" {
  name        = "${var.project_name} isolation SG ${var.stage}"
  description = "${var.project_name} isolation SG ${var.stage}"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = []
    self            = true
  }

  ingress {
    from_port       = 5001
    to_port         = 5001
    protocol        = "tcp"
    security_groups = []
    self            = true
  }
  ingress {
    from_port       = 5002
    to_port         = 5002
    protocol        = "tcp"
    security_groups = []
    self            = true
  }

  ingress {
    from_port       = 5003
    to_port         = 5003
    protocol        = "tcp"
    security_groups = []
    self            = true
  }
  ingress {
    from_port       = 5004
    to_port         = 5004
    protocol        = "tcp"
    security_groups = []
    self            = true
  }
  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.public_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-isolation-sg"
    project = "${var.project_name}"
    env     = var.stage
  }
}

#####################################
# PUBLIC Security Group
#####################################

resource "aws_security_group" "public_vpc_sg" {
  name        = "${var.project_name} Public SG ${var.stage}"
  description = "${var.project_name} Public SG ${var.stage}"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-public-sg"
    project = "${var.project_name}"
    env     = var.stage
  }
}

#####################################
# Public Facing attached to ALB
#####################################
resource "aws_security_group" "public_alb_sg" {
  name        = "${var.project_name}-ALB-${var.stage}"
  description = "Public Facing ALB"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-alb-sg"
    project = "${var.project_name}"
    env     = var.stage
  }
}

#####################################
#  Database Security Group
#####################################

resource "aws_security_group" "database_sg" {
  name        = "${var.project_name}-rds-sg-${var.stage}"
  description = "Security Group for RDS in ${var.stage} "
  vpc_id      = aws_vpc.vpc.id
  depends_on  = [aws_security_group.jumpbox_sg, aws_security_group.private_vpc_sg]
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.jumpbox_sg.id, aws_security_group.private_vpc_sg.id]
    self            = false
  }
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.tooling_vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["127.0.0.1/32"]
  }
  tags = {
    Shortname = var.project_name
    Name      = "${var.project_name} DB SG"
    stage     = var.stage
  }

}

#####################################
#  Jump box Security Group
#####################################
resource "aws_security_group" "jumpbox_sg" {
  name        = "${var.project_name}-jump-sg-${var.stage}"
  description = "Security Group for jumbox in ${var.stage}"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["127.0.0.1/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Shortname = var.project_name
    Name      = "${var.project_name} Jump SG"
    stage     = var.stage
  }
}

resource "aws_flow_log" "main" {
  iam_role_arn    = aws_iam_role.cloudwatch_log_role.arn
  log_destination = aws_cloudwatch_log_group.main.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.vpc.id
}

resource "aws_cloudwatch_log_group" "main" {
  name = "vpc-flow-logs"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cloudwatch_log_role" {
  name               = "cloudwatch_log_role_vpc_flow"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "cloudwatch_log_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cloudwatch_log_policy" {
  name   = "cloudwatch-policy-for-VPC-Flows"
  role   = aws_iam_role.cloudwatch_log_role.id
  policy = data.aws_iam_policy_document.cloudwatch_log_role_policy.json
}
