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
  if (app['rabbitmq_role'] & node.run_list.roles).any?
    app['rabbitmq_vhosts'].each do |environment, app_vhost|
      if environment.include? node.chef_environment
        rabbitmq_vhost app_vhost['vhost']

        rabbitmq_user app_vhost['user'] do
          vhost app_vhost['vhost']
          permissions %{".*" ".*" ".*"}

          if app_vhost['password']
            password app_vhost['password']
            action [:add, :set_permissions]
          else
            action :set_permissions
          end
        end
      end
    end
  end
end
