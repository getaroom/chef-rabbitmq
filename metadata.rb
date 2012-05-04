maintainer        "Opscode, Inc."
maintainer_email  "cookbooks@opscode.com"
license           "Apache 2.0"
description       "Installs and configures RabbitMQ server"
version           "1.4.1"
recipe            "rabbitmq", "Install and configure RabbitMQ"
recipe            "rabbitmq::plugins", "Enables and disables RabbitMQ plugins"
recipe            "rabbitmq::users", "Add and delete RabbitMQ users"
depends           "erlang", ">= 0.9"

%w{ubuntu debian redhat centos scientific}.each do |os|
  supports os
end

attribute "rabbitmq",
  :display_name => "RabbitMQ",
  :description => "Hash of RabbitMQ attributes",
  :type => "hash"

attribute "rabbitmq/nodename",
  :display_name => "RabbitMQ Erlang node name",
  :description => "The Erlang node name for this server.",
  :default => "node['hostname']"

attribute "rabbitmq/address",
  :display_name => "RabbitMQ server IP address",
  :description => "IP address to bind."

attribute "rabbitmq/port",
  :display_name => "RabbitMQ server port",
  :description => "TCP port to bind."

attribute "rabbitmq/config",
  :display_name => "RabbitMQ config file to load",
  :description => "Path to the rabbitmq.config file, if any."

attribute "rabbitmq/logdir",
  :display_name => "RabbitMQ log directory",
  :description => "Path to the directory for log files."

attribute "rabbitmq/mnesiadir",
  :display_name => "RabbitMQ Mnesia database directory",
  :description => "Path to the directory for Mnesia database files."

attribute "rabbitmq/max_open_files",
  :display_name => "RabbitMQ max open files",
  :description => "The max file desciptor limit on Debian and Ubuntu systems."

attribute "rabbitmq/version",
  :display_name => "RabbitMQ package version",
  :description => "The full RabbitMQ package version to install.",
  :default => "2.6.1-1"

attribute "rabbitmq/cluster",
  :display_name => "RabbitMQ clustering",
  :description => "Whether to activate clustering.",
  :default => "no"

attribute "rabbitmq/cluster_config",
  :display_name => "RabbitMQ clustering configuration file",
  :description => "Path to the clustering configuration file, if cluster is yes.",
  :default => "/etc/rabbitmq/rabbitmq_cluster.config"

attribute "rabbitmq/cluster_disk_nodes",
  :display_name => "RabbitMQ cluster disk nodes",
  :description => "Array of member Erlang nodenames for the disk-based storage nodes in the cluster.",
  :default => [],
  :type => "array"

attribute "rabbitmq/erlang_cookie",
  :display_name => "RabbitMQ Erlang cookie",
  :description => "Access cookie for clustering nodes.  There is no default."

attribute "rabbitmq/plugins",
  :display_name => "RabbitMQ plugins",
  :description => "The plugins to enable with the rabbitmq::plugins recipe.",
  :default => [],
  :type => "array"

attribute "rabbitmq/users_data_bag",
  :display_name => "RabbitMQ users data bags",
  :description => "Name of the data bag containing RabbitMQ users.",
  :default => "rabbitmq_users"

attribute "rabbitmq/users_data_bag_encrypted",
  :display_name => "RabbitMQ users data bag encrypted",
  :description => "Whether the RabbitMQ users data bag is encrypted.",
  :default => "no"
