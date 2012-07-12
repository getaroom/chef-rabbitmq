#
# Cookbook Name:: rabbitmq
# Provider:: plugin
#
# Copyright 2012, getaroom
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

action :enable do
  unless plugin_enabled?
    Chef::Log.info "Enabling RabbitMQ plugin '#{new_resource.name}'."
    shell_out! "rabbitmq-plugins enable #{new_resource.name}"
    new_resource.updated_by_last_action(true)
  end
end

action :disable do
  if plugin_enabled?
    Chef::Log.info "Disabling RabbitMQ plugin '#{new_resource.name}'."
    shell_out! "rabbitmq-plugins disable #{new_resource.name}"
    new_resource.updated_by_last_action(true)
  end
end

def plugin_enabled?
  name = new_resource.name
  pattern = "^#{Regexp.escape(name)}$"
  shell_out("rabbitmq-plugins list -m -E '#{pattern}' | grep #{name}").status.success?
end
