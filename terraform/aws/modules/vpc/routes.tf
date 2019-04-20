# Routing table for public subnet
resource "aws_route_table" "public" {
  count = "${length(var.az_public)}"

  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = "${merge(var.tags["values"],
    map(
      "Name", format("%s-%s-%s", "rt-public", lookup(var.tags["values"], "Name"), lookup(var.az_public[count.index], "az"))
  ))}"
}

# Route table associations
resource "aws_route_table_association" "public" {
  count = "${length(var.az_public)}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
}