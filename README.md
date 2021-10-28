# IKE Artifactory

This gem provides an object-oriented interface to Artifactory API for managing objects in Artfactory, 
particularly for cleaning up old Docker images

## Classes

Classes are located in `lib` directory. IKE:Artifactory implements two classes:

* `IKE::Artifactory::Client` class: Implements any method that calls Artifactory's API, and also other helpful methods.
  It is a layer between Artifactory's API and its users.
  
* `IKE::Artifactory::DockerCleaner` class: Using `IKE::Artifactory::Client` implements a single method called `cleanup!` 
  that let's you specify a path in Artifactory that has docker container image tags, a list of tags to be excluded, 
  other parameters; and will clean all container images meeting the resulting conditions created with the parameters.

## Script

The script is located in `bin` directory:

* `cleaner.rb`: A script to clean docker container images from a specified Artifactory repository. Read more about 
  this script in this [doc](README.cleaner.md)


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ike-artifactory-ruby'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install ike-artifactory-ruby

## Usage

```ruby
require 'ike-artifactor'
```
