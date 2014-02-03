require 'compass'
require 'susy'
require 'ostruct'


#-----------------------------------------------------------------------------
# Helpers
#-----------------------------------------------------------------------------

helpers do
end

#-----------------------------------------------------------------------------
# Plugins & Deployment
#-----------------------------------------------------------------------------

activate :directory_indexes

# Deploy stuff
# activate :sync do |sync|
#   sync.fog_provider = 'AWS'
#   sync.fog_directory = ENV['DEPLOY_BUCKET']
#   sync.fog_region = 'us-east-1'
#   sync.aws_access_key_id = ENV['AWS_ACCESS_KEY_ID']
#   sync.aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
#   sync.existing_remote_files = 'keep'
#   sync.gzip_compression = true
#   sync.after_build = false
# end

# activate :cloudfront do |cf|
#   cf.access_key_id = ENV['AWS_ACCESS_KEY_ID']
#   cf.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
#   cf.distribution_id = 'E6C5HNI8ML3GX'
#   cf.filter = /\.html$/i
#   cf.after_build = false
# end

#-----------------------------------------------------------------------------
# Build
#-----------------------------------------------------------------------------

configure :build do
  activate :gzip

  activate :asset_hash

  activate :minify_css
  activate :minify_javascript

  if ENV['DEPLOY_BRANCH']
    set :build_dir, "build/#{ ENV['DEPLOY_BRANCH'] }"
    set :http_prefix, "/#{ ENV['DEPLOY_BRANCH'] }"
  else
    set :http_prefix, '/'
  end
end
