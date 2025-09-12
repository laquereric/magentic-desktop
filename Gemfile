# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}.git" }

git_source(:tangent_opensource) do |repo_name|
    #"https://oauth2:YOUR_PERSONAL_ACCESS_TOKEN@github.com/laquereric/#{repo_name}.git"
    "https://github.com/laquereric/#{repo_name}.git"
end

gem "podman_cli", tangent_opensource: "podman_cli"
gem "lubuntu-gui", path: "../lubuntu-gui" #tangent_opensource: "lubuntu-gui"
gem "litellm_manager", tangent_opensource: "litellm_manager"
gem "buildah", tangent_opensource: "buildah"

# gem "rails"
