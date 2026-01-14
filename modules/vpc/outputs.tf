output "vpc_id" {
    value = aws_vpc.demo_vpc.id
}

output "vpc_name" {
    value = aws_vpc.demo_vpc.tags["Name"]
}

output "aws_subnet_private_1" {
    value = aws_subnet.pri_1.id
}

output "aws_subnet_private_2" {
    value = aws_subnet.pri_2.id
}

output "aws_public_subnets" {
    value = [aws_subnet.pub_1.id, aws_subnet.pub_2.id]
}