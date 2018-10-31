# VPC
resource "aws_vpc" "playground" {
  enable_dns_support   = true
  enable_dns_hostnames = true
  cidr_block           = "${var.cidr_block}"
}

# Internet Gateways
resource "aws_internet_gateway" "playground" {
  vpc_id = "${aws_vpc.playground.id}"
}

# Subnets
resource "aws_subnet" "playground" {
  availability_zone = "${var.default_zone}"
  cidr_block        = "${var.cidr_block}"
  vpc_id            = "${aws_vpc.playground.id}"
}

# Routing
resource "aws_route_table" "playground" {
  vpc_id = "${aws_vpc.playground.id}"
}

resource "aws_route" "playground_igw" {
  route_table_id         = "${aws_route_table.playground.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.playground.id}"
}

resource "aws_route_table_association" "playground" {
  subnet_id      = "${aws_subnet.playground.id}"
  route_table_id = "${aws_route_table.playground.id}"
}

# ACLs
resource "aws_network_acl" "playground" {
  vpc_id = "${aws_vpc.playground.id}"

  subnet_ids = [
    "${aws_subnet.playground.id}",
  ]
}

resource "aws_network_acl_rule" "egress_allow_all" {
  network_acl_id = "${aws_network_acl.playground.id}"
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
}

resource "aws_network_acl_rule" "ingress_allow_all" {
  network_acl_id = "${aws_network_acl.playground.id}"
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65535
}

# Security Groups
resource "aws_security_group" "playground" {
  name   = "playground"
  vpc_id = "${aws_vpc.playground.id}"
}

resource "aws_security_group_rule" "playground_in_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.playground.id}"
}

resource "aws_security_group_rule" "playground_in_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.playground.id}"
}

resource "aws_security_group_rule" "playground_in_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.playground.id}"
}

resource "aws_security_group" "internet_out" {
  name        = "internet-out"
  description = "Allow instances to connect to the Internet"
  vpc_id      = "${aws_vpc.playground.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
