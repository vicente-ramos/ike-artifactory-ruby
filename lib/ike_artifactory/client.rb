require 'time'
require 'json'
require 'rest-client'
require 'uri'
require 'pry-byebug'

module IKE
  module Artifactory
    class Client

      IMAGE_MANIFEST = 'manifest.json'

      attr_accessor :server
      attr_accessor :repo_key
      attr_accessor :folder_path
      attr_accessor :user
      attr_accessor :password

      def initialize(**args)
        @server = args[:server]
        @repo_key = args[:repo_key]
        @user = args[:user]
        @password = args[:password]

        raise IKEArtifactoryClientNotReady.new(msg = 'Required attributes are missing. IKEArtifactoryGem not ready.') unless self.ready?
      end

      def log_end_task
        "IKEArtifactoryGem end it's tasks"
      end

      def ready?
        if ([server, repo_key].include? nil ) || ([user, password].include? nil )
          return false
        end
        true
      end

      private :ready?

      def delete_object(path)
        RestClient::Request.execute(
          :method => :delete,
          :url => "#{server}/artifactory/api/storage/#{repo_key}/#{path}",
          :user => user,
          :password => password
        ) do |response, request, result|
          return response.code == 204
        end
      end

      def get_directories(path)
        directories = []
        RestClient::Request.execute(
          :method => :get,
          :url => "#{server}/artifactory/api/storage/#{repo_key}/#{path}",
          :user => user,
          :password => password
        ) do |response, request, result|
          if response.code == 200
            answer = JSON.parse response.to_str
            return directories unless answer.key?('children')

            answer['children'].each do |child|
              if child['folder']
                directories.append child['uri'][1..]
              end
            end
            return directories
          end
        end
      end

      def get_days_old(path)
        RestClient::Request.execute(
          :method => :get,
          :url => "#{server}/artifactory/api/storage/#{repo_key}/#{path}",
          :user => user,
          :password => password
        ) do |response, request, result|
          if response.code == 200
            answer = JSON.parse response.to_str
            return ( ( Time.now - Time.iso8601(answer['lastModified']) ) / (24*60*60) ).to_int
          else
            return -1
          end
        end
      end

      def get_object_info(path)
        RestClient::Request.execute(
          :method => :get,
          :url => "#{server}/artifactory/api/storage/#{repo_key}/#{path}",
          :user => user,
          :password => password
        ) do |response, request, result|
          if response.code == 200
            return JSON.parse response.to_str
          end
        end
      end

      def get_children(path)
        objects = {}
        RestClient::Request.execute(
          :method => :get,
          :url => "#{server}:443/ui/api/v1/ui/nativeBrowser/#{repo_key}/#{path}",
        ) do |response, request, result|
          if response.code == 200
            hash_path = JSON.parse response.to_str
            hash_path['children'].each do | child |
              days_old = ( ( Time.now.to_i - (child['lastModified']/1000) ) / (24*60*60) ).to_int
              objects[child['name']] = days_old
            end
          else
            return nil
          end
        end
        objects
      end

      def get_images(path)
        get_children(path).select do |(folder, _age)|
          get_object_info([path, folder, IMAGE_MANIFEST].join('/'))
        end
      end
    end
  end
end
