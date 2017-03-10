name 'jenkins_restore'
maintainer 'The Authors'
maintainer_email 'you@example.com'
license 'all_rights'
description 'Installs/Configures jenkins_restore'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'

# If you upload to Supermarket you should set this so your cookbook
# gets a `View Issues` link
# issues_url 'https://github.com/<insert_org_here>/jenkins_restore/issues' if respond_to?(:issues_url)

# If you upload to Supermarket you should set this so your cookbook
# gets a `View Source` link
# source_url 'https://github.com/<insert_org_here>/jenkins_restore' if respond_to?(:source_url)

depends 'awscli'
