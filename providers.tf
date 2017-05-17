# Openstack Provider

provider "openstack" {
  user_name   = "1. Enter K5 Username"
  password = "2. Enter K5 Password"
  tenant_name = "3. Enter K5 Target Project Name"
  domain_name = "4.Enter K5 Contract Name"
  # 5. Change the "uk-1" region below to match your target region
  auth_url = "https://identity.uk-1.cloud.global.fujitsu.com/v3"  

  insecure = true
}
