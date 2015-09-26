# chef-vagrant-aws
## Example Chef project using Vagrant that deploy to virtualbox and AWS

### The Vagrantfile

You can modify the Vagrant file to use with your project by editing following variables on the top
of the Vagrantfile:

```
server_name = 'webserver'
websites_source = './example_websites'
websites_destination = '/www'
```

This script was created for Ubuntu 12.04.You can change the local vagrant box name in the Vagrantfile. 
The aws image must by any image with `aws` provider enabled (it doesn't matter what image you put here so I use a dummy image).

```
box = {
 'virtualbox' => 'ubuntu/precise64',
 'aws' => 'dimroc/awsdummy'
}
```

Configure the ports redirection (for virtualbox):
```
http_port = 8000
https_port = 8443
```

You can also modify your VM parameters to match your AWS instances parameters:
```
guest_ram = 1024
guest_cpus = 1
```

# Websites configuration

Websites are configures using nginx-websites chef recipe which uses "websites" databag as a source of configuration to setup nginx.
Please read more here: https://github.com/ktunkiewicz/nginx-website

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
  "instances": 2,
  "balancer_enabled": false
}
```

Your keypair file should also be saved in .aws directory. Its name should be <server_name>-keypair.pem

### AWS components

The code expects that following components exists in your AWS setup:
- security group with name <server_name>-firewall
- keypair with name <server_name>-keypair
- (optional) balancer with name <server_name>-balancer

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
