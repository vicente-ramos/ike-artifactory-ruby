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

### Client

To create an instance of IKE::Artifactory::Client you will need to provide next parameters:
* *server*: Artifactory server URL. 
* *repo_key*: Repository in Artifactory server.
* *user*: Username to be used to access repository.
* *password*: User's password.

Example:
```ruby
require 'ike-artifactor'
require 'pp'

artifactory_client = IKE::Artifactory::Client(
        :server => 'https://artifactory.mydomain.com',
        :repo_key => 'repo-key-example',
        :user => 'Ana',
        :password => 'password'
)

object_info = artifactory_client.get_object_info 'path/to/object'

```
The output will be a hase with the proprieties of the queried object:
```ruby
irb > pp(object_info)
{"repo"=>"repo-key-example",
 "path"=>"path/to/object",
 "created"=>"2021-05-25T15:27:21.592-07:00",
 "createdBy"=>"some-user",
 "lastModified"=>"2021-05-25T15:27:21.592-07:00",
 "modifiedBy"=>"other-userr",
 "lastUpdated"=>"2021-05-25T15:27:21.592-07:00",
 "children"=>
  [{"uri"=>"/manifest.json", "folder"=>false},
   {"uri"=>
     "/sha256__4f07dd360c1b7e40c438e6437b2044bc31b4f6e5cf36b09a06b0c67e23dfc69d",
    "folder"=>false},
   {"uri"=>
     "/sha256__70fb9965a23f2226fef622992fdf507b8333c61d68259766d4721cc4ba1e5dae",
    "folder"=>false},
   {"uri"=>
     "/sha256__e0f9e11d6f9b3f5af2915fd4839ea0cd268ddccce28a788f54687b6a494770bb",
    "folder"=>false}],
 "uri"=>
  "https://artifactory.mydomain.com:443/artifactory/api/storage/repo-key-example/path/to/object"}
```





