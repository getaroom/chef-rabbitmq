#
# Cookbook Name:: rabbitmq
# Recipe:: default
#
# Copyright 2012, getaroom
# Copyright 2009, Benjamin Black
# Copyright 2009-2011, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# rabbitmq-server is not well-behaved as far as managed services goes
# we'll need to add a LWRP for calling rabbitmqctl stop
# while still using /etc/init.d/rabbitmq-server start
# because of this we just put the rabbitmq-env.conf in place and let it rip

include_recipe "erlang::default"

directory "/etc/rabbitmq/" do
  owner "root"
  group "root"
  mode 0755
  action :create
end

template "/etc/rabbitmq/rabbitmq-env.conf" do
  source "rabbitmq-env.conf.erb"
  owner "root"
  group "root"
  mode 0644
  # notifies :restart, "service[rabbitmq-server]"
end

group "rabbitmq" do
  system true
end

user "rabbitmq" do
  comment "RabbitMQ messaging server"
  group "rabbitmq"
  home "/var/lib/rabbitmq"
  system true
end

if node['rabbitmq']['logdir']
  directory node['rabbitmq']['logdir'] do
    owner "rabbitmq"
    group "rabbitmq"
    mode 0755
    recursive true
    action :create
  end

  link "/var/log/rabbitmq" do
    to node['rabbitmq']['logdir']
  end
end

directory node['rabbitmq']['mnesiadir'] do
  owner "rabbitmq"
  group "rabbitmq"
  mode 0755
  recursive true
  action :create
end if node['rabbitmq']['mnesiadir']

if node['rabbitmq']['erlang_cookie']
  directory "/var/lib/rabbitmq" do
    owner "rabbitmq"
    group "rabbitmq"
    mode 0755
    action :create
  end

  # If this already exists, don't do anything
  # Changing the cookie will stil have to be a manual process
  template "/var/lib/rabbitmq/.erlang.cookie" do
    source "doterlang.cookie.erb"
    owner "rabbitmq"
    group "rabbitmq"
    mode 0400
    not_if { File.exists? "/var/lib/rabbitmq/.erlang.cookie" }
  end
end

package_source_base = "https://www.rabbitmq.com/releases/rabbitmq-server/v#{node['rabbitmq']['version']}"

case node[:platform]
when "debian", "ubuntu"
  package_file = "rabbitmq-server_#{node['rabbitmq']['version']}-1_all.deb"

  remote_file "#{Chef::Config[:file_cache_path]}/#{package_file}" do
    source "#{package_source_base}/#{package_file}"
    action :create_if_missing
  end

  dpkg_package "#{Chef::Config[:file_cache_path]}/#{package_file}" do
    action :install
  end

  if node['init_package'] == 'systemd'
    directory "/etc/systemd/system/rabbitmq-server.service.d" do
      owner "root"
      group "root"
    end

    template "/etc/systemd/system/rabbitmq-server.service.d/limits.conf" do
      source "limits.conf.erb"
      owner "root"
      group "root"
      mode 0644
      notifies :restart, "service[rabbitmq-server]"
    end
  else
    template "/etc/default/rabbitmq-server" do
      source "rabbitmq-server-default.erb"
      owner "root"
      group "root"
      mode 0644
      notifies :restart, "service[rabbitmq-server]"
    end
  end

when "redhat", "centos", "scientific", "amazon"
  package_file = "rabbitmq-server-#{node['rabbitmq']['version']}-1.noarch.rpm"

  remote_file "#{Chef::Config[:file_cache_path]}/#{package_file}" do
    source "#{package_source_base}/#{package_file}"
    action :create_if_missing
  end

  rpm_package "#{Chef::Config[:file_cache_path]}/#{package_file}" do
    action :install
  end
end

template "/etc/rabbitmq/rabbitmq.config" do
  source "rabbitmq.config.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, "service[rabbitmq-server]", :immediately
end

service "rabbitmq-server" do
  stop_command "/usr/sbin/rabbitmqctl stop"
  supports :status => true, :restart => true
  action [ :enable, :start ]
end
