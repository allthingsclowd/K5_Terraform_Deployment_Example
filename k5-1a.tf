##### AZ2 Resources

#
## Keypair
#
resource "openstack_compute_keypair_v2" "tf-test-keypair-1a" {
  name       = "tf-test-keypair-1a"
  region     = "uk-1"
  public_key = "${file(var.ssh_public_key_file)}"

  value_specs = {
    availability_zone = "uk-1a"
  }
}

#
## Floating IP - NOTE: Commented out as K5 does not support router creation and FIP creation in same step
#
# resource "openstack_networking_floatingip_v2" "tf_nc_test_fip_1a" {
#  region = "uk-1"
#  pool   = "inf_az1_ext-net02"

#  value_specs = {
#    availability_zone = "uk-1a"
#  }
# }

#
# Create a router for our network
#
resource "openstack_networking_router_v2" "tf_nc_test_rtr_1a" {
  region                  = "uk-1"
  name                    = "tf_nc_test_rtr_1a"
  admin_state_up          = "true"
  external_gateway        = "df8d3f21-75f2-412a-8fd9-29de9b4a4fa8"
  # update_external_gateway = true

  value_specs = {
    availability_zone = "uk-1a"
  }
}

#
# Create a Network
#
resource "openstack_networking_network_v2" "tf_nc_test_1a" {
  region         = "uk-1"
  name           = "tf_nc_test_1a"
  admin_state_up = "true"

  value_specs = {
    availability_zone = "uk-1a"
  }
}

# Create a subnet
resource "openstack_networking_subnet_v2" "tf_nc_test_1a_subnet" {
  region = "uk-1"
  name   = "tf_nc_test_1a_subnet"
  cidr   = "192.168.70.0/24"

  allocation_pools = {
    start = "192.168.70.2"
    end   = "192.168.70.250"
  }

  gateway_ip      = "192.168.70.1"
  dns_nameservers = ["8.8.8.8"]
  ip_version      = "4"
  network_id      = "${openstack_networking_network_v2.tf_nc_test_1a.id}"

  host_routes = [
    {
      destination_cidr = "192.168.71.0/24"
      next_hop         = "192.168.70.253"
    },
  ]

  value_specs = {
    availability_zone = "uk-1a"
  }
}

# Create a port for connecting Router to Subnet
resource "openstack_networking_port_v2" "tf_nc_test_rtr_1a_subnet_int" {
  region         = "uk-1"
  name           = "tf_nc_test_rtr_1a_subnet_int"
  network_id     = "${openstack_networking_network_v2.tf_nc_test_1a.id}"
  admin_state_up = "true"

  /* security_group_ids = ["${openstack_networking_secgroup_v2.tf_nc_test_sec_cross_az_1a.id}"] */
  fixed_ip = {
    subnet_id  = "${openstack_networking_subnet_v2.tf_nc_test_1a_subnet.id}"
    ip_address = "${openstack_networking_subnet_v2.tf_nc_test_1a_subnet.gateway_ip}"
  }

  value_specs = {
    availability_zone = "uk-1a"
  }
}

#
# Attach the Router to our Network via an Interface
#
resource "openstack_networking_router_interface_v2" "tf_nc_test_rtr_1a_if_1" {
  region    = "uk-1"
  router_id = "${openstack_networking_router_v2.tf_nc_test_rtr_1a.id}"
  port_id   = "${openstack_networking_port_v2.tf_nc_test_rtr_1a_subnet_int.id}"

  /* subnet_id = "${openstack_networking_subnet_v2.tf_nc_test_1a_subnet.id}" */
}

# Create an instance
resource "openstack_compute_instance_v2" "tf_nc_test_1a_instance_1" {
  region = "uk-1"
  name   = "tf_nc_test_1a_instance_1"

  /* image_id = "78081613-30fd-4e73-999b-bec9949c7a76" */
  flavor_name       = "T-1"
  key_pair          = "${openstack_compute_keypair_v2.tf-test-keypair-1a.name}"
  availability_zone = "uk-1a"
  security_groups   = ["${openstack_networking_secgroup_v2.tf_nc_test_sec_1.name}"]

  metadata {
    demo = "metadata"
  }

  block_device {
    uuid                  = "58fd966f-b055-4cd0-9012-cf6af7a4c32b"
    source_type           = "image"
    volume_size           = "30"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    uuid = "${openstack_networking_network_v2.tf_nc_test_1a.id}"
  }

 # NOTE: Commented out as K5 does not support router creation and FIP creation in same script
  /* floating_ip = "${openstack_networking_floatingip_v2.tf_nc_test_fip_1a.address}" */

  /* depends_on = ["openstack_networking_router_interface_v2.tf_nc_test_rtr_1_if_1"] */
}
