#
# Cookbook Name:: rabbitmq
# Recipe:: apps
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

search(:apps) do |app|
  if (node.run_list.roles & Array(app['rabbitmq_role'])).any?
    Array(app['rabbitmq_vhosts'][node.chef_environment]).each do |app_vhost|
      rabbitmq_vhost app_vhost['vhost']

      Array(app_vhost['users']).each do |user|
        user_actions = []
        user_actions << :add if user['password']
        user_actions << :set_tags if user['tags']
        user_actions << :set_permissions

        rabbitmq_user user['user'] do
          vhost app_vhost['vhost']
          permissions user['permissions']
          password user['password'] if user['password']
          action user_actions
        end
      end
    end
  end
end
