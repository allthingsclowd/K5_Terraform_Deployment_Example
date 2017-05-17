#
# Create a security group and rules
#
resource "openstack_networking_secgroup_v2" "tf_nc_test_sec_1" {
  region      = "uk-1"
  name        = "tf_nc_test_sec_1"
  description = "Security Group Via Terraform"
}

resource "openstack_networking_secgroup_rule_v2" "tf_nc_test_sec_rule_egress_metadata" {
  region            = "uk-1"
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "169.254.169.254/32"
  security_group_id = "${openstack_networking_secgroup_v2.tf_nc_test_sec_1.id}"
}

resource "openstack_networking_secgroup_rule_v2" "tf_nc_test_sec_1_rule_icmp_in" {
  region            = "uk-1"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.tf_nc_test_sec_1.id}"
}

resource "openstack_networking_secgroup_rule_v2" "tf_nc_test_sec_1_rule_ssh_in" {
  region            = "uk-1"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.tf_nc_test_sec_1.id}"
}
