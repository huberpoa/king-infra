resource "aws_subnet" "public" {
  count = "${length(var.az_public)}"

  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${lookup(var.az_public[count.index], "cidr")}"
  availability_zone       = "${lookup(var.az_public[count.index], "az")}"
  map_public_ip_on_launch = true

  tags = "${merge(var.tags["values"],
    map(
    "Name", format("%s-%s-%s", "public", lookup(var.tags["values"], "Name"), lookup(var.az_public[count.index], "az"))
  ))}"
}

# Internet gateway for the public subnet
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = "${merge(var.tags["values"],
    map(
    "Name", format("%s-%s", lookup(var.tags["values"], "Name"), lookup(var.az_public[count.index], "az"))
  ))}"
}