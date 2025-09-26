# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}.git" }

git_source(:tangent_opensource) do |repo_name|
    #"https://oauth2:YOUR_PERSONAL_ACCESS_TOKEN@github.com/laquereric/#{repo_name}.git"
    "https://github.com/laquereric/#{repo_name}.git"
end

git_source(:laquereric_opensource) do |repo_name|
    #"https://oauth2:YOUR_PERSONAL_ACCESS_TOKEN@github.com/laquereric/#{repo_name}.git"
    "https://github.com/laquereric/#{repo_name}.git"
end

gem 'yard-rails'
gem 'yard-activerecord'

gem "lubuntu-gui", tangent_opensource: "lubuntu-gui"
gem "nebius-cli-ruby", laquereric_opensource: "nebius-cli-ruby"
