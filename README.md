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

### IKE::Artifactory::Client

To create an instance of IKE::Artifactory::Client you will need to provide next parameters:
* **server**: Artifactory server URL. 
* **repo_key**: Repository in Artifactory server.
* **user**: Username to be used to access repository.
* **password**: User's password.

#### Example
```ruby
require 'ike-artifactor'

artifactory_client = IKE::Artifactory::Client.new(
        :server => 'https://artifactory.mydomain.com',
        :repo_key => 'repo-key-example',
        :user => 'Ana',
        :password => 'password'
)

object_info = artifactory_client.get_object_info 'path/to/object'
```

The output will be a hash with the proprieties of the queried object:
```ruby
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

#### Methods

##### `delete_object(path)`
Returns *true* if the object pointed by path was successfully deleted. Returns *false* in other wise.

##### `get_subdirectories(path)`
Returns array of strings. Each string is a names of a subdirectory.

##### `get_days_old(path)`
Returns an integer that is the days old (lastModified) of the object pointed by path. Returns -1 other wise. 

##### `get_object_info(path)`
Returns a hash with the proprieties of the queried object.

##### `get_subdirectories_by_days_old(path)`
Returns a hash with keys being a string with the name of a subdirectory and the value is an integer that is the days 
old of the subdirectory (lastModified).

##### `get_images(path)`
Returns a hash with keys being a string with the name of a subdirectory containing `IMAGE_MANIFEST` file. The value
is an integer that is the days old of the subdirectory.

### IKE::Artifactory::DockerCleaner

To create an instance of IKE::Artifactory::DockerCleaner you will need to provide next parameters:
* **repo_host**: Artifactory server URL.
* **repo_key**: Repository in Artifactory server.
* **folder**: Path to a folder having container images (tags).
* **days_old**: The maximum number of days old a container image can have before being selected for deletion.
* **most_recent_images**: N number of newest container images to keep it regardless how many days old are they. 
* **images_exclude_list**: Array of container images names (tags) to be excluded from deletion.
* **user**: Username to be used to access repository.
* **password**: User's password.
* **log_level** (optional): Default to ::Logger::INFO.
* **actually_delete** (optional): Default to false.

#### Example
```ruby
require 'ike-artifactor'

images_to_delete = IKE::Artifactory::DockerCleaner.new(
        :server => 'https://artifactory.mydomain.com',
        :repo_key => 'repo-key-example',
        :folder => 'path/to/folder',
        :days_old => 30,
        :most_recent_images => 5,
        :images_exclude_list => ['tag1', 'tag2', 'tag3'],
        :user => 'Ana',
        :password => 'password'
).cleanup!

puts images_to_delete
```
Returns an array of strings. Each string is the tag of the container image to be deleted if *actually_delete* is true.
```ruby
['tag-x', 'tag-y', 'tag-z']
```
