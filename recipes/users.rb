#
# Cookbook Name:: rabbitmq
# Recipe:: users
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

users = if node['rabbitmq']['users_data_bag_encrypted']
  data_bag(node['rabbitmq']['users_data_bag']).map do |user_id|
    Chef::EncryptedDataBagItem.load(node['rabbitmq']['users_data_bag'], user_id)
  end
else
  search(node['rabbitmq']['users_data_bag'], "*:*")
end

users.each do |user|
  rabbitmq_user user['id'] do
    if user['action'] == "delete"
      action :delete
    else
      password user['password']

      if user['tags']
        tags user['tags']
        action [:add, :set_tags]
      end
    end
  end
end
