#!/bin/bash

gem install bundler

bundle install && bundle exec librarian-chef install --path chef/cookbooks

vagrant plugin install vagrant-librarian-chef
vagrant plugin install vagrant-hostsupdater