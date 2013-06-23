Code.require_file "../test_helper.exs", __FILE__

defmodule Expm.Test.Repository.Auth do
  use ExUnit.Case

  setup do
    repo = Expm.Repository.ETS.new
    {:ok, [repo: repo]}
  end

  test "uploading a new package", data do
    package = Expm.Package.new(name: "test", version: "0.1")
    auth = Expm.Repository.Auth.new(repository: data[:repo], username: "user", auth_token: "password")
    package = Expm.Package.publish auth, package
    assert Expm.Package[name: "test", version: "0.1"] = package
    assert package.metadata[:published_by] == "user"
  end

  test "uploading a new package with mix", data do
    auth = Expm.Repository.Auth.new(repository: data[:repo], username: "user", auth_token: "password")
    package = Mix.Tasks.Publish.publish(auth)
    assert package.metadata[:published_by] == "user"
  end

  test "uploading a package with the same version", data do
    package = Expm.Package.new(name: "test", version: "0.1")
    auth = Expm.Repository.Auth.new(repository: data[:repo], username: "user", auth_token: "password")
    package = Expm.Package.publish auth, package
    assert ^package = Expm.Package.publish auth, package
  end

  test "uploading a package with another version", data do
    package = Expm.Package.new(name: "test", version: "0.1")
    auth = Expm.Repository.Auth.new(repository: data[:repo], username: "user", auth_token: "password")
    Expm.Package.publish auth, package
    package = Expm.Package.new(name: "test", version: "0.2")    
    package = Expm.Package.publish auth, package
    package = Expm.Package.publish auth, package
    assert Expm.Package[name: "test", version: "0.2"] = package
    assert package.metadata[:published_by] == "user"    
  end

  test "uploading a package with the same version with an incorrect username", data do
    package = Expm.Package.new(name: "test", version: "0.1")
    auth = Expm.Repository.Auth.new(repository: data[:repo], username: "user", auth_token: "password")
    package = Expm.Package.publish auth, package
    auth = Expm.Repository.Auth.new(repository: data[:repo], username: "user1", auth_token: "password")
    assert {:error, :access_denied} = Expm.Package.publish auth, package
  end  

  test "uploading a package with the same version with an incorrect password", data do
    package = Expm.Package.new(name: "test", version: "0.1")
    auth = Expm.Repository.Auth.new(repository: data[:repo], username: "user", auth_token: "password")
    package = Expm.Package.publish auth, package
    auth = Expm.Repository.Auth.new(repository: data[:repo], username: "user", auth_token: "password1")
    assert {:error, :access_denied} = Expm.Package.publish auth, package
  end  

  test "uploading a package with another version with an incorrect username", data do
    package = Expm.Package.new(name: "test", version: "0.1")
    auth = Expm.Repository.Auth.new(repository: data[:repo], username: "user", auth_token: "password")
    Expm.Package.publish auth, package
    auth = Expm.Repository.Auth.new(repository: data[:repo], username: "user1", auth_token: "password")    
    package = Expm.Package.new(name: "test", version: "0.2")    
    assert {:error, :access_denied} = Expm.Package.publish auth, package
  end

  test "uploading a package with another version with an incorrect password", data do
    package = Expm.Package.new(name: "test", version: "0.1")
    auth = Expm.Repository.Auth.new(repository: data[:repo], username: "user", auth_token: "password")
    Expm.Package.publish auth, package
    auth = Expm.Repository.Auth.new(repository: data[:repo], username: "user", auth_token: "password1")    
    package = Expm.Package.new(name: "test", version: "0.2")    
    assert {:error, :access_denied} = Expm.Package.publish auth, package
  end

  test "deleting a specific version of a package", data do
    package = Expm.Package.new(name: "test", version: "0.1")
    auth = Expm.Repository.Auth.new(repository: data[:repo], username: "user", auth_token: "password")
    package = Expm.Package.publish auth, package
    assert :ok = Expm.Package.delete auth, package
    assert :not_found = Expm.Package.fetch auth, package.name, package.version
  end

  test "deleting all versions of a package", data do
    package = Expm.Package.new(name: "test", version: "0.1")
    auth = Expm.Repository.Auth.new(repository: data[:repo], username: "user", auth_token: "password")
    Expm.Package.publish auth, package
    package = Expm.Package.new(name: "test", version: "0.2")    
    package = Expm.Package.publish auth, package    
    assert :ok = Expm.Package.delete auth, package.name
    assert :not_found = Expm.Package.fetch auth, package.name, "0.1"    
    assert :not_found = Expm.Package.fetch auth, package.name, "0.2"    
  end

  test "deleting a specific version of a package with an incorrect username", data do
    package = Expm.Package.new(name: "test", version: "0.1")
    auth = Expm.Repository.Auth.new(repository: data[:repo], username: "user", auth_token: "password")
    package = Expm.Package.publish auth, package
    auth = Expm.Repository.Auth.new(repository: data[:repo], username: "user1", auth_token: "password")    
    assert {:error, :access_denied} = Expm.Package.delete auth, package
  end  

  test "deleting a specific version of a package with an incorrect password", data do
    package = Expm.Package.new(name: "test", version: "0.1")
    auth = Expm.Repository.Auth.new(repository: data[:repo], username: "user", auth_token: "password")
    package = Expm.Package.publish auth, package
    auth = Expm.Repository.Auth.new(repository: data[:repo], username: "user", auth_token: "password1")    
    assert {:error, :access_denied} = Expm.Package.delete auth, package
  end  

  test "deleting a all versions of a package with an incorrect username", data do
    package = Expm.Package.new(name: "test", version: "0.1")
    auth = Expm.Repository.Auth.new(repository: data[:repo], username: "user", auth_token: "password")
    Expm.Package.publish auth, package
    package = Expm.Package.new(name: "test", version: "0.2")    
    package = Expm.Package.publish auth, package    
    auth = Expm.Repository.Auth.new(repository: data[:repo], username: "user1", auth_token: "password")    
    assert {:error, :access_denied} = Expm.Package.delete auth, package
  end  

  test "deleting a all versions of a package with an incorrect password", data do
    package = Expm.Package.new(name: "test", version: "0.1")
    auth = Expm.Repository.Auth.new(repository: data[:repo], username: "user", auth_token: "password")
    Expm.Package.publish auth, package
    package = Expm.Package.new(name: "test", version: "0.2")    
    package = Expm.Package.publish auth, package        
    auth = Expm.Repository.Auth.new(repository: data[:repo], username: "user", auth_token: "password1")    
    assert {:error, :access_denied} = Expm.Package.delete auth, package
  end  


end
