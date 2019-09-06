# terraform-training
This example creates the following configuration:
1. Creates VCN with one public and one private subnets with Internet GW and NAT GW (to enable internet connectivity for web servers on the private subnet)
2. Creates and configures  ‘public’ and ‘private’ security lists and routing tables
3. Creates a bastion on the public subnet
4. Creates number of web servers on the private subnet (the number of web servers is controlled by NumInstances variable)
5. Using cloud-init it installs and configures httpd on the web servers and opens FW ports  
6. Create a LB, LB listeners, backend set and configureis the web servers as LB backend servers

All compute instances and LB are created with a tag ‘TF-lab.owner’ = ‘student<number>’.

### Using this example
* Update env-vars with the required information. Most examples use the same set of environment variables so you only need to do this once.
* Source env-vars
  * `$ . env-vars`
* Update `variables.tf` with your instance options. You may also modify the `NumInstances` and `NumVolumesPerInstance` variables to change the number of instances and volumes that are launched.

### Files in the configuration

#### `env-vars`
Is used to export the environmental variables used in the configuration. 

Before you plan, apply, or destroy the configuration source the file -  
`$ . env-vars`

#### `variables.tf`
Defines the variables used in the configuration

#### `provider.tf`
Specifies and passes authentication details to the OCI TF provider

#### `network.tf`
Creates VCN, public and private subnets with associated route tables and security lists

#### `instance.tf`
Creates bastion instance on the public subnet and web servers instances on the private subnet. 
Installs httpd on the server servers and opens firewall ports

#### `lb.tf`
Create a LB, LB listeners, backend set and configures the web servers as LB backend servers

