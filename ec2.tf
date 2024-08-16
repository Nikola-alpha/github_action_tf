resource "aws_instance" "tf_s3" {
  ami           = "ami-0a6b545f62129c495"
  instance_type = "t2.micro"
  tags = {
    Name = "deadpool"
  }
}