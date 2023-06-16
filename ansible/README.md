To be able to run Ansible(thru run-ansible), you need first to run the following script in the root directory 
of this repository:

`launchcontainer`

This will start a docker and you'll run your ansible in it with all the 
required dependencies.

WARNING: This run-ansible accept only 1 parameter, the AWS Environment(dev, staging, prod). By example, you cannot pass '--check' or 
anything else.