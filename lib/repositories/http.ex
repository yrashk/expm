defrecord Expm.Repository.HTTP, url: "https://expm.co", username: nil, password: nil do
  alias :hackney, as: H

  def version(repo) do
    {:ok, 200, _headers, client} = 
      H.request("GET", "#{repo.url}/__version__",
                [
                 {"content-type","text/html"},
                 {"accept", "text/html"},
                 {"user-agent", "expm/#{Expm.version}"},                 
                ],
                "", [follow_redirect: true, force_redirect: true])
    {:ok, body, client} = H.body(client)
    H.close(client)
    body
  end

end


defmodule Expm.Repository.HTTP.Decoder do
  defexception SecurityException, message: nil

  def decode({ :__block__, _, [b] }) when is_list(b) do
    decode_1(b)
  end

  def decode(v) do
    raise SecurityException.new(message: "#{Macro.to_binary(v)} is not allowed")  
  end


  def decode_1({ _a, _b, _c }=v) do
    raise SecurityException.new(message: "#{Macro.to_binary(v)} is not allowed")
  end

  def decode_1({ a, b }) do
    { decode_1(a), decode_1(b) }
  end

  def decode_1(list) when is_list(list) do
    lc i inlist list, do: decode_1(i)
  end

  def decode_1(other) do
    other
  end
end

defimpl Expm.Repository, for: Expm.Repository.HTTP do
  
  alias :hackney, as: H

  def get(repo, package, version) do
    {:ok, code, _headers, client} = 
      H.request("GET", "#{repo.url}/#{to_binary(package)}/#{to_binary(version)}",
                [
                 {"content-type","application/elixir"},
                 {"accept", "application/elixir"},
                 {"user-agent", "expm/#{Expm.version}"},
                ],
                "", [follow_redirect: true, force_redirect: true])
    {:ok, body, client} = H.body(client)
    H.close(client)
    case code do
      200 ->
        Expm.Package.decode body  
      _ -> :not_found
    end
  end

  def versions(repo, package) do
    {:ok, code, _headers, client} = 
      H.request("GET", "#{repo.url}/#{package}",
                [
                 {"content-type","application/elixir"},
                 {"accept", "application/elixir"},
                 {"user-agent", "expm/#{Expm.version}"},
                ],
                "", [follow_redirect: true, force_redirect: true])
    {:ok, body, client} = H.body(client)
    H.close(client)
    case code do
      200 ->
        Expm.Repository.HTTP.Decoder.decode Code.string_to_quoted!(body)
      _ -> []
    end
  end

  def put(Expm.Repository.HTTP[username: username, 
                               password: password], _spec)
                                 when nil?(username) or
                                      nil?(password) do
      {:error, :authentication_required}                                                        
  end      

  def put(repo, spec) do
    {:ok, code, _headers, client} = 
      H.request("PUT", "#{repo.url}/#{spec.name}",
                [{"authorization",%b{Basic #{:base64.encode("#{repo.username}:#{repo.password}")}}},
                 {"content-type","application/elixir"},
                 {"accept", "application/elixir"},
                 {"user-agent", "expm/#{Expm.version}"},              
                 ],
                spec.encode, [follow_redirect: true, force_redirect: true])
    {:ok, body, client} = H.body(client)
    H.close(client)
    case code do
      200 ->
        Expm.Package.decode body
      _ -> :error
    end
  end

  def delete(repo, package, version) do
    {:ok, code, _headers, client} = 
      H.request("DELETE", "#{repo.url}/#{package}/#{version}",
                [{"authorization",%b{Basic #{:base64.encode("#{repo.username}:#{repo.password}")}}},
                 {"content-type","application/elixir"},
                 {"accept", "application/elixir"},
                 {"user-agent", "expm/#{Expm.version}"},          
                 ],
                "", [follow_redirect: true, force_redirect: true])
    {:ok, body, client} = H.body(client)
    H.close(client)
    case code do
      code in [200,204] ->
        :ok
      _ -> {:error, code, body}
    end
  end
  
  def list(repo, filter) do
    {:ok, code, _headers, client} = 
      H.request("PUT", "#{repo.url}",
                [
                 {"content-type","application/elixir"},
                 {"accept", "application/elixir"},
                 {"user-agent", "expm/#{Expm.version}"},         
                 ],
                filter.encode, [follow_redirect: true, force_redirect: true])
    {:ok, body, client} = H.body(client)
    H.close(client)
    case code do 
      200 ->
        Expm.Package.decode body
      _ ->
        []
    end
  end

end