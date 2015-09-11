# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

#
# VIRTUALBOX & AWS VAGRANTFILE
#
# This Vagrantfile works fine with virtualbox and AWS.
#
# You can modify the project name below:

project = 'blurobot'
project_files = '../BluRobotWebApp'

#
# This script was created for Ubuntu 12.04 but it should work fine with any distribution.
# You can change the local vagrant name below, the aws image must by any image with `aws` provider enabled
# (it doesn't matter what image you put here so I use a dummy image).
#
box = {
 'virtualbox' => 'ubuntu/precise64',
 'aws' => 'dimroc/awsdummy'
}

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
#   "instance_username": "ubuntu"
# }
#
# The code expects that following components exists in your AWS setup:
# - security group with name <project_name>-firewall
# - balancer with name <project_name>-balancer
# - keypair with name <project_name>-keypair
#
# Your keypair file should also be saved in .aws directory. Its name should be <project_name>-keypair.pem
# (it will have such name when you download it from AWS, so just don't change it)
#
#
# -------------------------------------------------------------------------------
#

args = Hash[ ARGV.join(' ').scan(/--?([^=\s]+)(?:=(\S+))?/) ]
supported_providers = %w(virtualbox aws)
provider = args['provider'].nil? ? 'virtualbox' : args['provider']

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = box[provider]
  config.vm.network "forwarded_port", guest: 80, host: 2000

  config.vm.define "#{project}_#{provider}"
  config.vm.synced_folder project_files, "/webapps/#{project}", owner: "www-data", group: "www-data"

  #
  # VirtualBox
  #
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  #
  # AWS
  #
  config.vm.provider "aws" do |aws, override|
    aws_json = JSON.parse(Pathname(__FILE__).dirname.join('.aws', 'config.json').read)
    aws.elb               = "#{project}-balancer"
    aws.keypair_name      = "#{project}-keypair"
    aws.security_groups   = [ "#{project}-firewall" ]
    aws.tags              = { 'Project' => "#{project}" }
    aws.ami               = aws_json['ami']
    aws.region            = aws_json['region']
    aws.instance_type     = aws_json['instance_type']
    aws.access_key_id     = aws_json['access_key_id']
    aws.secret_access_key = aws_json['secret_access_key']
    override.ssh.username = aws_json['instance_username']
    override.ssh.private_key_path = Pathname(__FILE__).dirname.join('.aws', "#{project}-keypair.pem")
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
  vagrant_json = JSON.parse(Pathname(__FILE__).dirname.join('nodes', "#{provider}.json").read)
  config.vm.provision :chef_solo do |chef|
     chef.cookbooks_path = [ "cookbooks", "site-cookbooks" ]
     chef.roles_path = "roles"
     chef.data_bags_path = "data_bags"
     chef.run_list = vagrant_json.delete('run_list') if vagrant_json['run_list']
     chef.json = vagrant_json
  end

end
