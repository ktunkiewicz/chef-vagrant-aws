# chef-vagrant-aws
## Example Chef project using Vagrant that deploy to virtualbox and AWS

### The Vagrantfile

You can modify the Vagrant file to use with your project by editing following variables on the top
of the Vagrantfile:

```
project = 'blurobot'
project_files = '../BluRobotWebApp'
```

This script was created for Ubuntu 12.04 but it should work with others distributions as well.
You can change the local vagrant box name in the Vagrantfile. 
The aws image must by any image with `aws` provider enabled (it doesn't matter what image you put here so I use a dummy image).

```
box = {
 'virtualbox' => 'ubuntu/precise64',
 'aws' => 'dimroc/awsdummy'
}
```

# The AWS configuration

Example configuration file `.aws/config.json`

```json
{
  "access_key_id": "xxxxx",
  "secret_access_key": "xxxxxxxx",
  "ami": "ami-47a23a30",
  "region": "eu-west-1",
  "instance_type": "t2.micro",
  "instance_username": "ubuntu",
  "instances": 2
}
```

You also have to put your keypair file in the .aws folder.

### AWS components

The code expects that following components exists in your AWS setup:
- security group with name project_name-firewall
- balancer with name project_name-balancer
- keypair with name project_name-keypair

## Usage

You can use normal Vagrant commands like `vagrant up`, `vagrant halt` etc. to work in your local enviroment.

In order to setup AWS instances you need to add `--provider=aws` before your Vagrant command
(With one exception - I don't know why but in case of `up` command you have to specify the provider *after* the `up` command...)

Example commands:

`vagrant up --provider=aws`

Will bring up all AWS instances (and provision if you do that for the first time)

`vagrant --provider=aws provision`

Will provision all instances

`vagrant --provider=aws ssh blurobot1_aws`

Will ssh into first AWS instance.


`vagrant --provider=aws destroy`

Will destroy all instances
