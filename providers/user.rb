#
# Cookbook Name:: rabbitmq
# Provider:: user
#
# Copyright 2012, getaroom
# Copyright 2011, Opscode, Inc.
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

include Chef::Mixin::ShellOut

action :add do
  unless shell_out("rabbitmqctl list_users | grep #{new_resource.user}").status.success?
    Chef::Log.info "Adding RabbitMQ user '#{new_resource.user}'."
    shell_out! "rabbitmqctl add_user #{new_resource.user} #{new_resource.password}"
    new_resource.updated_by_last_action(true)
  end
end

action :delete do
  execute "rabbitmqctl delete_user #{new_resource.user}" do
    only_if "rabbitmqctl list_users | grep #{new_resource.user}"
    Chef::Log.info "Deleting RabbitMQ user '#{new_resource.user}'."
    new_resource.updated_by_last_action(true)
  end
end

action :set_permissions do
  permissions_pattern = new_resource.permissions.split.map do |permission|
    Regexp.escape permission.gsub(/^\"(.*)\"$/, "\\1")
  end.join("[[:space:]]")

  pattern = "^#{Regexp.escape(new_resource.vhost)}[[:space:]]#{permissions_pattern}"

  execute "rabbitmqctl set_permissions -p #{new_resource.vhost} #{new_resource.user} #{new_resource.permissions}" do
    not_if "rabbitmqctl list_user_permissions #{new_resource.user} | egrep '#{pattern}'"
    Chef::Log.info "Setting RabbitMQ user permissions for '#{new_resource.user}' on vhost #{new_resource.vhost}."
    new_resource.updated_by_last_action(true)
  end
end

action :clear_permissions do
  if new_resource.vhost
    execute "rabbitmqctl clear_permissions -p #{new_resource.vhost} #{new_resource.user}" do
      only_if "rabbitmqctl list_user_permissions | grep #{new_resource.user}"
      Chef::Log.info "Clearing RabbitMQ user permissions for '#{new_resource.user}' from vhost #{new_resource.vhost}."
      new_resource.updated_by_last_action(true)
    end
  else
    execute "rabbitmqctl clear_permissions #{new_resource.user}" do
      only_if "rabbitmqctl list_user_permissions | grep #{new_resource.user}"
      Chef::Log.info "Clearing RabbitMQ user permissions for '#{new_resource.user}'."
      new_resource.updated_by_last_action(true)
    end
  end
end

action :set_tags do
  execute "rabbitmqctl set_user_tags #{new_resource.user} #{new_resource.tags.join(' ')}" do
    not_if "rabbitmqctl list_users | egrep '#{Regexp.escape(new_resource.user)}[[:space:]]\\[#{Regexp.escape(new_resource.tags.join(', '))}\\]'"
    Chef::Log.info "Setting RabbitMQ user tags for '#{new_resource.user}'."
    new_resource.updated_by_last_action(true)
  end
end
