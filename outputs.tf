output "vpc" {
  value = {
    id = "${aws_vpc.vpc.id}"
  }
}
