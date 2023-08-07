resource "aws_key_pair" "pmh_key" {
  key_name = "${var.name}-key"
  public_key = file("./pmh.pub")
}

resource "aws_instance" "pmh_bastion" {
  ami                    = var.ami
  instance_type          = "t2.micro"
  key_name               = "${var.name}-key"
  vpc_security_group_ids = [aws_security_group.eks_secu.id]
  availability_zone      = "${var.region}a"
  user_data = templatefile("./eks.sh", {
    region                = var.region,
    cluname               = var.cluname,
    access_key            = var.access_key,
    secret_key            = var.secret_key,
    ACM_ARN               = var.ACM_ARN,
    FluentBitHttpPort     = var.FluentBitHttpPort,
    FluentBitReadFromHead = var.FluentBitReadFromHead,
    FluentBitHttpServer   = var.FluentBitHttpServer,
    FluentBitReadFromTail = var.FluentBitReadFromTail,
  })
  subnet_id                   = aws_subnet.public[0].id
  associate_public_ip_address = true

  tags = {
    Name = "${var.name}-bastion"
  }
  depends_on = [
    aws_eks_cluster.eks_clu
  ]
}

output "pub_ip" {
  value = aws_instance.pmh_bastion.public_ip
}
