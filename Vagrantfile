# -*- mode: ruby -*-
# vi: set ft=ruby :

#
# This project allows you to deploy a typical PHP web server:
# - Nginx                  web server
# - php-fpm or HHVM        php engine
#
# Supported providers are:
# - Virtualbox             for local development
# - AWS                    with many instances and balancer support
# - possibly more in future
#
#
# Name your server below.
# The server name is used in many places (ex. naming instances or keypairs in AWS).
#
server_name = 'webserver'

#
# All websites that will be deployed to this server must be located in the below directory
# The `./example_websites` folder is where soome example website is placed, you probably want to change that to
# path where you keep your website code. The path can be absolute or relative.
#
websites_source = './example_websites'

# This is where websites are stored on the server
# You need to know that value to properly setup `root` property in `websites` data bag.
#
websites_destination = '/www'

#
# This script was created for Ubuntu 12.04
# You can change images for each provider below.
#
box = {
 'virtualbox' => 'ubuntu/precise64',
 'aws' => 'dimroc/awsdummy'
}

#
# Guest virtualbox machine port mappings for ports 80 and 443:
#
http_port = 8000
https_port = 8443

#
# Guest virtualbox machine hardware specs
#
guest_ram = 1024
guest_cpus = 1

#
# Components
# (comment the components that you don't want on your server)
#
run_list = [
    "role[web]",
    "role[phpfpm]",
    "role[hhvm]"
]

#
# ------ AWS provider ------- 
#
# Configuration of the AWS account should be placed in .aws/config.json file
# If you are using Ubuntu you can locate the correct AMI id here: http://cloud-images.ubuntu.com/locator/ec2/
#
# Example of .aws/config.json file:
# {
#   "access_key_id": "your_access_key_id",
#   "secret_access_key": "your_secret_access_key",
#   "ami": "ami-fdf6d78a",
#   "region": "eu-west-1",
#   "instance_type": "t2.micro",
#   "instance_username": "ubuntu",
#   "instances": 1,
#   "balancer_enabled": false
# }
#
# The code expects that following components exists in your AWS setup:
# - security group with name <server_name>-firewall
# - keypair with name <server_name>-keypair
# - (optional) balancer with name <server_name>-balancer
#
# Your keypair file should also be saved in .aws directory. Its name should be <server_name>-keypair.pem
#
#
# -------------------------------------------------------------------------------
#

VAGRANTFILE_API_VERSION = "2"
args = Hash[ ARGV.join(' ').scan(/--?([^=\s]+)(?:=(\S+))?/) ]
supported_providers = %w(virtualbox aws)
provider = args['provider'].nil? ? 'virtualbox' : args['provider']

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = box[provider]
  config.vm.network "forwarded_port", guest: 80, host: http_port
  config.vm.network "forwarded_port", guest: 443, host: https_port

  config.vm.synced_folder File.absolute_path(websites_source), websites_destination, owner: "www-data", group: "www-data"

  aws_json = JSON.parse(Pathname(__FILE__).dirname.join('.aws', 'config.json').read)
  if provider != "virtualbox"
    for i in 1..aws_json['instances']
      config.vm.define "#{server_name}#{i}_#{provider}"
    end
  else
    config.vm.define "#{server_name}_#{provider}"
  end

  #
  # VirtualBox
  #
  config.vm.provider "virtualbox" do |vb|
    vb.memory = guest_ram
    vb.cpus = guest_cpus
  end

  #
  # AWS
  #
  config.vm.provider "aws" do |aws, override|
    aws.keypair_name      = "#{server_name}-keypair"
    aws.security_groups   = [ "#{server_name}-firewall" ]
    aws.tags              = { 'Name' => "#{server_name}_#{provider}" }
    aws.ami               = aws_json['ami']
    aws.region            = aws_json['region']
    aws.instance_type     = aws_json['instance_type']
    aws.access_key_id     = aws_json['access_key_id']
    aws.secret_access_key = aws_json['secret_access_key']
    override.ssh.username = aws_json['instance_username']
    override.ssh.private_key_path = Pathname(__FILE__).dirname.join('.aws', "#{server_name}-keypair.pem")
    if aws_json['balancer_enabled'] then aws.elb = "#{server_name}-balancer" end
  end

  #
  # Install Chef
  #
  $script = <<SCRIPT
    test -e /usr/bin/chef-solo && exit
    curl -sL https://www.opscode.com/chef/install.sh | bash
SCRIPT
  config.vm.provision :shell, :inline => $script

  #
  # Run Chef
  #
  config.vm.provision :chef_solo do |chef|
     chef.cookbooks_path = [ "cookbooks", "site-cookbooks" ]
     chef.roles_path = "roles"
     chef.data_bags_path = "data_bags"
     chef.run_list = run_list
     chef.json = {
       "provider" => provider,
       "nginx-website" => {
         "bag" => "websites-#{provider}"
       }
     }
  end

end
