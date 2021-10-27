require "test_helper"


TIME_LAST_MODIFIED_MILLISECONDS = (Time.now.to_i - 30*24*60*60) * 1000

class UnitTestClientClass < Minitest::Test

  def setup
    super
    @artifactory = IKE::Artifactory::Client.new()
  end

  def test_server_arg
    artifactory = IKE::Artifactory::Client.new(**{:server => 'some-fake-server'}) # should not fail
    assert artifactory.server == 'some-fake-server'
  end

  def test_repo_key_arg
    artifactory = IKE::Artifactory::Client.new(**{:repo_key => 'some-fake-repo_key'}) # should not fail
    assert artifactory.repo_key == 'some-fake-repo_key'
  end

  def test_folder_path_arg
    artifactory = IKE::Artifactory::Client.new(**{:folder_path => 'some-fake-folder_path'}) # should not fail
    assert artifactory.folder_path == 'some-fake-folder_path'
  end

  def test_user_arg
    artifactory = IKE::Artifactory::Client.new(**{:user => 'some-fake-user'}) # should not fail
    assert artifactory.user == 'some-fake-user'
  end

  def test_password_arg
    artifactory = IKE::Artifactory::Client.new(**{:password => 'some-fake-password'}) # should not fail
    assert artifactory.password == 'some-fake-password'
  end

  def test_server_attribute
    assert @artifactory.respond_to? :server
    assert @artifactory.respond_to? :server=
  end

  def test_repo_key_attribute
    assert @artifactory.respond_to? :repo_key
    assert @artifactory.respond_to? :repo_key=
  end

  def test_folder_path_attribute
    assert @artifactory.respond_to? :folder_path
    assert @artifactory.respond_to? :folder_path=
  end

  def test_user_attribute
    assert @artifactory.respond_to? :user
    assert @artifactory.respond_to? :user=
  end

  def test_password_attribute
    assert @artifactory.respond_to? :password
    assert @artifactory.respond_to? :password=
  end

  def test_logs_end_of_work
    assert_equal "IKEArtifactoryGem end it's tasks", @artifactory.log_end_task
  end

end

class UnitTestClientMethods < Minitest::Test

  def setup
    super
    @artifactory = IKE::Artifactory::Client.new(**{
      :server => TEST_SERVER,
      :repo_key => TEST_REPO_KEY,
      :folder_path => TEST_FOLDER_PATH,
      :user => TEST_USER,
      :password => TEST_PASSWORD
    })
  end

  def test_not_ready
    artifactory = IKE::Artifactory::Client.new()
    refute artifactory.ready?
  end

  def test_ready
    artifactory = IKE::Artifactory::Client.new(**{
      :server => TEST_SERVER,
      :repo_key => TEST_REPO_KEY,
      :folder_path => TEST_FOLDER_PATH,
      :user => TEST_USER,
      :password => TEST_PASSWORD
    })
    assert artifactory.ready?
  end

  def test_no_password
    artifactory = IKE::Artifactory::Client.new(**{
      :server => TEST_SERVER,
      :repo_key => TEST_REPO_KEY,
      :folder_path => TEST_FOLDER_PATH,
      :user => TEST_USER
    })
    refute artifactory.ready?
  end

  def test_no_auth_data
    artifactory = IKE::Artifactory::Client.new(**{
      :server => TEST_SERVER,
      :repo_key => TEST_REPO_KEY,
      :folder_path => TEST_FOLDER_PATH
    })
    refute artifactory.ready?
  end

  def test_no_server
    artifactory = IKE::Artifactory::Client.new(**{
      :repo_key => TEST_REPO_KEY,
      :folder_path => TEST_FOLDER_PATH,
      :api_token => TEST_API_TOKEN
    })
    refute artifactory.ready?
  end

  def test_get_object_info_raise_not_ready
    artifactory = IKE::Artifactory::Client.new()
    exception = assert_raises IKE::Artifactory::IKEArtifactoryClientNotReady do
      artifactory.get_object_info 'fake-object'
    end
    assert_equal('Required attributes are missing. IKEArtifactoryGem not ready.', exception.message)
  end

  def test_get_object_info_call_get_api
    mock_request = Minitest::Mock.new
    mock_request.expect :call,
                        true,
                        [:method => :get,
                         :url => @artifactory.server + '/artifactory/api/storage/' + @artifactory.repo_key + '/' + 'fake-object',
                         :user => @artifactory.user, :password => @artifactory.password]

    RestClient::Request.stub :execute, mock_request do
      @artifactory.get_object_info 'fake-object'
    end
    assert_mock mock_request
  end

  def test_get_object_info_return_nil_if_fail
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 404
    mock_response.expect :to_str, '{ "test": "fake" }'

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake-request', 'fake-result'] do
      result = @artifactory.get_object_info 'fake-object'
      assert_nil result
    end
  end

  def test_get_object_info_json_parse_called
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 200
    mock_response.expect :to_str, '{ "test": "fake" }'
    mock_json = Minitest::Mock.new
    mock_json.expect :call,
                     {"test" => "fake"},
                     ['{ "test": "fake" }']

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake-request', 'fake-result'] do
      JSON.stub :parse, mock_json do
        @artifactory.get_object_info 'fake-object'
      end
    end
    assert_mock mock_json
  end

  def test_get_object_info_return_json_parse_result
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 200
    mock_response.expect :to_str, '{ "test": "fake" }'
    mock_json = Minitest::Mock.new
    mock_json.expect :call,
                     {"test" => "fake-fake##"},
                     ['{ "test": "fake" }']

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake-request', 'fake-result'] do
      JSON.stub :parse, mock_json do
        result = @artifactory.get_object_info 'fake-object'
        assert_equal({"test" => "fake-fake##"}, result)
      end
    end
  end

  def test_get_days_old_raise_not_ready
    artifactory = IKE::Artifactory::Client.new()
    exception = assert_raises IKE::Artifactory::IKEArtifactoryClientNotReady do
      artifactory.get_days_old '/fake'
    end
    assert_equal('Required attributes are missing. IKEArtifactoryGem not ready.', exception.message)
  end

  def test_get_days_old_call_get_api
    mock_request = Minitest::Mock.new
    mock_request.expect :call,
                        true,
                        [:method => :get,
                         :url =>@artifactory.server + '/artifactory/api/storage/' + @artifactory.repo_key + '/' + 'fake-object',
                         :user => @artifactory.user, :password => @artifactory.password]

    RestClient::Request.stub :execute, mock_request do
      @artifactory.get_days_old 'fake-object'
    end
    assert_mock mock_request
  end

  def test_get_days_old_return_negative_if_fail
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 404
    mock_response.expect :to_str, '{ "test": "fake" }'

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake-request', 'fake-result'] do
      result = @artifactory.get_days_old 'fake-object'
      assert_equal(-1, result)
    end
  end

  def test_get_days_old_json_parse_called
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 200
    mock_response.expect :to_str, '{ "test": "fake", "lastModified": "2021-09-14T12:27:00.10" }'
    mock_json = Minitest::Mock.new
    mock_json.expect :call,
                     { "test" => "fake", "lastModified" => "2021-09-14T12:27:00.10" },
                     ['{ "test": "fake", "lastModified": "2021-09-14T12:27:00.10" }']

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake-request', 'fake-result'] do
      JSON.stub :parse, mock_json do
        @artifactory.get_days_old 'fake-object'
      end
    end
    assert_mock mock_json
  end

  def test_get_days_old_call_time_with_last_updated
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 200
    mock_response.expect :to_str, '{ "test": "fake", "lastModified": "2021-09-14T12:27:00.10" }'
    mock_time = Minitest::Mock.new
    mock_time.expect :call, Time.now, ['2021-09-14T12:27:00.10']

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake-request', 'fake-result'] do
      JSON.stub :parse, { 'uri' => 'fake-host', 'lastModified' => '2021-09-14T12:27:00.10'} do
        Time.stub :iso8601, mock_time do
          @artifactory.get_days_old 'fake-object'
        end
      end
    end
    assert_mock mock_time
  end

  def test_get_days_old_call_time_now
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 200
    mock_response.expect :to_str, '{ "test": "fake", "lastModified": "2021-09-14T12:27:00.10" }'
    mock_time = Minitest::Mock.new
    mock_time.expect :call, Time.now, []

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake-request', 'fake-result'] do
      JSON.stub :parse, { 'uri' => 'fake-host', 'lastModified' => '2021-09-14T12:27:00.10'} do
        Time.stub :now, mock_time do
          @artifactory.get_days_old 'fake-object'
        end
      end
    end
    assert_mock mock_time
  end

  def test_get_days_old_return_days_subtract
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 200
    mock_response.expect :to_str, '{ "test": "fake", "lastModified": "2021-09-14T12:27:00.10" }'

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake-request', 'fake-result'] do
      JSON.stub :parse, { 'uri' => 'fake-host', 'lastModified' => '2021-09-14T12:27:00.10'} do
        Time.stub :iso8601, (Time.now - (20*24*60*60)) do
          result = @artifactory.get_days_old 'fake-object'
          assert_equal 20, result
        end
      end
    end
  end

  def test_delete_object_raise_not_ready
    artifactory = IKE::Artifactory::Client.new()
    exception = assert_raises IKE::Artifactory::IKEArtifactoryClientNotReady do
      artifactory.delete_object 'fake-object'
    end
    assert_equal('Required attributes are missing. IKEArtifactoryGem not ready.', exception.message)
  end

  def test_delete_object_call_get_api
    mock_request = Minitest::Mock.new
    mock_request.expect :call,
                        true,
                        [:method => :delete,
                         :url => @artifactory.server + '/artifactory/' + @artifactory.repo_key + '/' + 'fake-object',
                         :user => @artifactory.user, :password => @artifactory.password]

    RestClient::Request.stub :execute, mock_request do
      @artifactory.delete_object 'fake-object'
    end
    assert_mock mock_request
  end

  def test_delete_object_return_nil_if_fail
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 404

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake-request', 'fake-result'] do
      result = @artifactory.delete_object 'fake-object'
      refute result
    end
  end

  def test_delete_object_return_object_deleted
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 204
    mock_response.expect :to_str, '{ "test": "fake" }'
    mock_json = Minitest::Mock.new
    mock_json.expect :call,
                     {"test" => "fake"},
                     ['{ "test": "fake" }']

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake-request', 'fake-result'] do
      result = @artifactory.delete_object 'fake-object'
      assert result
    end
  end

  def test_get_directories_raise_not_ready
    artifactory = IKE::Artifactory::Client.new()
    exception = assert_raises IKE::Artifactory::IKEArtifactoryClientNotReady do
      artifactory.get_directories('/fake')
    end
    assert_equal('Required attributes are missing. IKEArtifactoryGem not ready.', exception.message)
  end

  def test_get_directories_folder_path_is_default
    mock_request = Minitest::Mock.new
    mock_request.expect :call,
                        true,
                        [:method => :get,
                         :url => @artifactory.server + '/artifactory/api/storage/' + @artifactory.repo_key + '/' +
                           @artifactory.folder_path + '/',
                         :user => @artifactory.user, :password => @artifactory.password]

    RestClient::Request.stub :execute, mock_request do
      @artifactory.get_directories
    end
    assert_mock mock_request
  end

  def test_get_directories_folder_path_parameter
    mock_request = Minitest::Mock.new
    mock_request.expect :call,
                        true,
                        [:method => :get,
                         :url => @artifactory.server + '/artifactory/api/storage/' + @artifactory.repo_key + '/fake/',
                         :user => @artifactory.user, :password => @artifactory.password]

    RestClient::Request.stub :execute, mock_request do
      @artifactory.get_directories 'fake'
    end
    assert_mock mock_request
  end

  def test_get_directories_return_nil_if_not_connect
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 401

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake1', 'fake2' ] do
      result = @artifactory.get_directories
      assert result.nil?
    end
  end

  def test_get_directories_return_empty_array
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 200
    mock_response.expect :to_str, '{ "test": "fake" }'

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake1', 'fake2' ] do
      result = @artifactory.get_directories
      assert_instance_of Array, result
      assert_empty result
    end
  end

  def test_get_directories_json_parse_called
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 200
    mock_response.expect :to_str, '{ "test": "fake" }'
    mock_json_parse = Minitest::Mock.new
    mock_json_parse.expect :call, {:fake => 'fake'}, ['{ "test": "fake" }']

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake1', 'fake2' ] do
      JSON.stub :parse, mock_json_parse do
        @artifactory.get_directories
      end
    end
    assert_mock mock_json_parse
  end

  def test_get_directories_loop_children_returns_uri
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 200
    mock_response.expect :to_str, '{ "children": [{"uri": "/fake1", "folder": true},{"uri": "/fake2", "folder": true}] }'

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake1', 'fake2' ] do
      result = @artifactory.get_directories
      assert_includes result, 'fake1'
      assert_includes result, 'fake2'
    end
  end

  def test_get_directories_returns_only_folders
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 200
    mock_response.expect :to_str, '{ "children": [{"uri": "/fake1", "folder": true},{"uri": "/fake2", "folder": false}] }'

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake1', 'fake2' ] do
      result = @artifactory.get_directories
      assert_includes result, 'fake1'
      refute_includes result, 'fake2'
    end
  end

  def test_get_objects_by_days_old_raise
    artifactory = IKE::Artifactory::Client.new()
    exception = assert_raises IKE::Artifactory::IKEArtifactoryClientNotReady do
      artifactory.get_objects_by_days_old 'fake-path'
    end
    assert_equal('Required attributes are missing. IKEArtifactoryGem not ready.', exception.message)
  end

  def test_get_objects_by_days_old_call_get_api
    mock_request = Minitest::Mock.new
    mock_request.expect :call,
                        true,
                        [:method => :get,
                         :url => @artifactory.server + '/artifactory/api/storage/' + @artifactory.repo_key + '/' + 'fake-path',
                         :user => @artifactory.user, :password => @artifactory.password]

    RestClient::Request.stub :execute, mock_request do
      @artifactory.get_objects_by_days_old 'fake-path'
    end
    assert_mock mock_request
  end

  def test_get_objects_by_days_old_return_nil_if_fail
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 404
    mock_response.expect :to_str, '{ "children": [{"uri": "/fake1", "folder": true},{"uri": "/fake2", "folder": false}] }'

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake-request', 'fake-result'] do
      result = @artifactory.get_objects_by_days_old 'fake-path'
      assert_nil result
    end
  end

  def test_get_objects_by_days_old_call_get_info_on_each_children
    time = Time.now - 30*24*60*60
    last_modified = time.strftime('%Y-%m-%dT%H:%M:%S.%L%z')

    mock_get_object_info = Minitest::Mock.new
    mock_get_object_info.expect :call,
                                { 'createdBy' => 'someone', 'path' => 'fake-path', 'lastModified' => last_modified },
                                ['fake-path/fake1']
    mock_get_object_info.expect :call,
                                { 'createdBy' => 'someone', 'path' => 'fake-path', 'lastModified' => last_modified },
                                ['fake-path/fake2']

    mock_response = Minitest::Mock.new
    mock_response.expect :code, 200
    mock_response.expect :to_str,
                         '{ "children": [{"uri": "/fake1", "folder": true},{"uri": "/fake2", "folder": false}] }'
    mock_response.expect :code, 200
    mock_response.expect :to_str,
                         '{ "children": [{"uri": "/fake1", "folder": true},{"uri": "/fake2", "folder": false}] }'

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake-request', 'fake-result'] do
      @artifactory.stub :get_object_info, mock_get_object_info do
        @artifactory.stub :get_days_old, 10 do
          @artifactory.get_objects_by_days_old 'fake-path'
        end
      end
    end
    assert_mock mock_get_object_info
  end

  def test_get_objects_by_days_old_return_object_and_days
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 200
    mock_response.expect :to_str, '{ "children": [{"uri": "/fake1", "folder": true}] }'

    time = Time.now - 30*24*60*60
    last_modified = time.strftime('%Y-%m-%dT%H:%M:%S.%L%z')

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake-request', 'fake-result'] do
      @artifactory.stub :get_object_info, {'createdBy' => 'Bob',
                                                             'path' => 'fake-path/object',
                                           'lastModified' => last_modified } do
        @artifactory.stub :get_days_old, 30 do
          result = @artifactory.get_objects_by_days_old 'fake-path'
          assert_equal({'object' => 30}, result)
        end
      end
    end
  end

  def test_get_children_raise_not_ready
    artifactory = IKE::Artifactory::Client.new()
    exception = assert_raises IKE::Artifactory::IKEArtifactoryClientNotReady do
      artifactory.get_children 'fake-path'
    end
    assert_equal('Required attributes are missing. IKEArtifactoryGem not ready.', exception.message)
  end

  def test_get_children_call_get_api
    mock_request = Minitest::Mock.new
    mock_request.expect :call,
                        true,
                        [:method => :get,
                         :url => "#{@artifactory.server}:443/ui/api/v1/ui/nativeBrowser/#{@artifactory.repo_key}/fake-path"]

    RestClient::Request.stub :execute, mock_request do
      @artifactory.get_children 'fake-path'
    end
    assert_mock mock_request
  end

  def test_get_children_return_nil_if_fail
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 404
    mock_response.expect :to_str, '{ "children": [{"name": "fake1", "folder": true},{"name": "fake2", "folder": false}] }'

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake-request', 'fake-result'] do
      result = @artifactory.get_children 'fake-path'
      assert_nil result
    end
  end

  def test_json_parse_called
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 200
    mock_response.expect :to_str, '{ "children": [{"name": "fake1", "folder": true},{"name": "fake2", "folder": false}] }'
    mock_json_parse = Minitest::Mock.new
    mock_json_parse.expect :call,
                           { 'children' => [{ 'name' => 'fake1', "folder" => true, "lastModified" => TIME_LAST_MODIFIED_MILLISECONDS },
                                            { 'name' => 'fake2', "folder" => false, "lastModified" => TIME_LAST_MODIFIED_MILLISECONDS }]},
                           ['{ "children": [{"name": "fake1", "folder": true},{"name": "fake2", "folder": false}] }']

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake-request', 'fake-result'] do
      JSON.stub :parse, mock_json_parse do
        @artifactory.get_children 'fake-path'
      end
    end
    assert_mock mock_json_parse
  end

  def test_for_each_children_return_a_hash_key
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 200
    mock_response.expect :to_str, '{ "fake": "fake" }'
    object_info =  { 'children' => [
        { 'name' => 'fake1', "folder" => true, "lastModified" => TIME_LAST_MODIFIED_MILLISECONDS },
        { 'name' => 'fake2', "folder" => false, "lastModified" => TIME_LAST_MODIFIED_MILLISECONDS }]}

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake-request', 'fake-result'] do
      JSON.stub :parse, object_info do
        objects = @artifactory.get_children 'fake-path'
        assert objects.has_key?('fake1')
        assert objects.has_key?('fake2')
      end
    end
  end

  def test_returned_object_value_is_days_old
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 200
    mock_response.expect :to_str, '{ "fake": "fake" }'
    object_info =  { 'children' => [
      { 'name' => 'fake1', "folder" => true, "lastModified" => TIME_LAST_MODIFIED_MILLISECONDS },
      { 'name' => 'fake2', "folder" => false, "lastModified" => TIME_LAST_MODIFIED_MILLISECONDS }]}

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake-request', 'fake-result'] do
      JSON.stub :parse, object_info do
        objects = @artifactory.get_children 'fake-path'
        assert_equal 30, objects['fake1']
        assert_equal 30, objects['fake2']
      end
    end
  end
end



