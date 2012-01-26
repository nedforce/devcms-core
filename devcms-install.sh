#!/bin/sh

# Check for Git
if [ ! -x `which git` ]; then
  echo "DevCMS requires Git. Please install Git."
  exit
fi

# Check for Git
ruby -v | grep "1.8.7"
if [ $? -gt 0 ]; then
  echo "DevCMS requires Ruby 1.8.7. Please install it, using RubyVersionManager is recommended."
  exit
fi


# Check for Rails version
if [ ! "`rails -v`" = "Rails 2.3.14" ]; then
  echo "DevCMS requires Ruby on Rails version 2.3.14. Please execute 'gem install rails -v=2.3.14'"
  exit
fi

# Check for Rails app
if [ ! -f "config/boot.rb" ]; then
  echo "Please run this installer from within a (new) Rails application. You can create one by running 'rails APPLICATION NAME'"
  exit
fi

if [ ! -x `which convert` ]; then
  echo "DevCMS requires ImageMagick. Please install it."
  exit
fi

git init

# Install Engines
echo "==> Installing Engines plugin"
script/plugin install git://github.com/lazyatom/engines.git
# Install DevCMS
echo "==> Installing DevCMS"
git submodule add git://github.com/nedforce/devcms-core.git vendor/plugins/devcms-core

# Install gems
echo "==> Installing required gems"
gem install faker --version "0.3.1"
gem install pg --version "~> 0.11.0"
gem install sqlite3
gem install rcov --version "~> 0.9.11"
gem install ferret --version "~> 0.11.6"
gem install soap4r
gem install haml
gem install rmagick
gem install dsl_accessor --version "0.3.3"
rake devcms:install
rake gems:install

echo "==> Committing changes"
git add .
git commit -a -m "Initial commit"

cat <<@

Done! Please edit config/database.yml to suit your needs. Then execute db:create
and db:migrate to setup the database. From there you have two choices:

 1. Populate the database with a small example structure using 'rake db:populate:all'
 
 2. Seed the database with a minimal structure using 'rake db:seed'
 
From there on you can run the server and log in with the username 'webmaster'
and the password 'admin'.

@
