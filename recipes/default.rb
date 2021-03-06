#
# Cookbook Name:: jenkins_restore
# Recipe:: default
#
# Copyright (c) 2017 The Authors, All Rights Reserved.
include_recipe "awscli::default"

#InstanceMetadata.wait_for_instance_IAM_metadata_to_be_available()

service "jenkins" do
    action :stop
end

#Find Latest backup of Jenkins in specified S3 Bucket.
ruby_block "latest_JenkinsBackup" do
    block do
        node.override['jenkins_restore']['file'] = `aws s3 ls #{node['jenkins_restore']['s3bucket']} | sort | tail -n 1 | awk '{print $4}'`
        node.override['jenkins_restore']['file'] = node['jenkins_restore']['file'].strip
        
        node.override['jenkins_restore']['buildid'] = node['jenkins_restore']['file'].scan(/.*_(\d+)/).first[0]
        
        Chef::Log.info("Jenkins Backup Path: #{node['jenkins_restore']['s3bucket']}")
        Chef::Log.info("Jenkins Backup File: #{node['jenkins_restore']['file']}")
        Chef::Log.info("Jenkins Build ID: #{node['jenkins_restore']['buildid']}")
    end
    action :nothing
end.run_action(:run)

execute 'awsCPjenkins' do
  command "aws s3 cp s3://#{node['jenkins_restore']['s3bucket']}#{node['jenkins_restore']['file']} /usr/tmp/jenkins_restore.tar.gz"
end

file '/usr/tmp/jenkins_restore.tar.gz' do
    only_if { ::File.exist?('/usr/tmp/jenkins_restore.tar.gz') }
    action :touch
end

execute 'extract_jenkins_restore_tar' do
  command 'tar -xvzf jenkins_restore.tar.gz'
  cwd '/usr/tmp/'
  only_if { ::File.exist?('/usr/tmp/jenkins_restore.tar.gz') }
end

#cp *.xml /var/lib/jenkins/
execute 'cp_xml' do
  command 'cp *.xml /var/lib/jenkins/'
  cwd "/usr/tmp/#{node['jenkins_restore']['buildid']}/"
end

#cp identity.key* /var/lib/jenkins/
execute 'cp_identity' do
  command 'cp identity.key* /var/lib/jenkins/'
  cwd "/usr/tmp/#{node['jenkins_restore']['buildid']}/"
end

#cp secret.key* /var/lib/jenkins/
execute 'cp_secretkey' do
  command 'cp secret.key* /var/lib/jenkins/'
  cwd "/usr/tmp/#{node['jenkins_restore']['buildid']}/"
end

#cp -r secrets/ /var/lib/jenkins/
execute 'cp_secrets' do
  command 'cp -r secrets/ /var/lib/jenkins/'
  cwd "/usr/tmp/#{node['jenkins_restore']['buildid']}/"
end

#cp -r plugins/ /var/lib/jenkins/
execute 'cp_plugins' do
  command 'cp -r plugins/ /var/lib/jenkins/'
  cwd "/usr/tmp/#{node['jenkins_restore']['buildid']}/"
end

#cp -r users/ /var/lib/jenkins/
execute 'cp_users' do
  command 'cp -r users/ /var/lib/jenkins/'
  cwd "/usr/tmp/#{node['jenkins_restore']['buildid']}/"
end

#rsync -am --include='config.xml' --include='*/' --prune-empty-dirs --exclude='*' jobs/ /var/lib/jenkins/jobs/
execute 'rsync_jobs' do
  command 'rsync -am --include='config.xml' --include='*/' --prune-empty-dirs --exclude='*' jobs/ /var/lib/jenkins/jobs/'
  cwd "/usr/tmp/#{node['jenkins_restore']['buildid']}/"
end

service 'jenkins' do
  supports status: true, restart: true, reload: true
  action  [:enable, :start]
end

service "httpd" do
    action [:start,:enable]
end
