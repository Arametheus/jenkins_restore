#
# Cookbook Name:: jenkins_restore
# Recipe:: default
#
# Copyright (c) 2017 The Authors, All Rights Reserved.


#InstanceMetadata.wait_for_instance_IAM_metadata_to_be_available()

service "jenkins" do
    action :stop
end


ruby_block "s3file" do
    block do
        #tricky way to load this Chef::Mixin::ShellOut utilities
        Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)      
        command = "aws s3 ls #{node['jenkins_restore']['s3bucket']} | sort | tail -n 1 | awk '{print $4}'"
        command_out = shell_out(command)
        node.set['jenkins_restore']['file'] = command_out.stdout
    end
    action :create
end

Chef::Log.info("Jenkins Backup File: #{node['jenkins_restore']['file']}")



#execute 'awsCPjenkins' do
#  command 'aws s3 cp s3://flw-backup/jenkins/2017-03-08-054800_690.tar.gz /usr/tmp/jenkins_restore.tar.gz'
#end




#aws s3 cp s3://flw-backup/jenkins/$KEY /usr/tmp/jenkins_restore.tar.gz



 
#tar -xvzf jenkins_restore.tar.gz

#cd {build number}

#cp *.xml /var/lib/jenkins/

#cp identity.key* /var/lib/jenkins/
#cp secret.key* /var/lib/jenkins/
#cp -r secrets/ /var/lib/jenkins/
#cp -r plugins/ /var/lib/jenkins/

#cp -r users/ /var/lib/jenkins/


#rsync -am --include='config.xml' --include='*/' --prune-empty-dirs --exclude='*' jobs/ /var/lib/jenkins/jobs/



#service "jenkins" do
#    action [:start,:enable]
#end

#service "httpd" do
#    action [:start,:enable]
#end
