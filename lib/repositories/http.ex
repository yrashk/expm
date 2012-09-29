defrecord Expm.Repository.HTTP, url: "http://expm.co", username: nil, password: nil


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
    {:ok, 200, _headers, client} = 
      H.request("GET", "#{repo.url}/#{package}/#{version}",
                [
                 {"content-type","application/elixir"},
                ],
                "", [follow_redirect: true])
    {:ok, body, client} = H.body(client)
    H.close(client)
    Expm.Package.decode body  
  end

  def versions(repo, package) do
    {:ok, 200, _headers, client} = 
      H.request("GET", "#{repo.url}/#{package}",
                [
                 {"content-type","application/elixir"},
                ],
                "", [follow_redirect: true])
    {:ok, body, client} = H.body(client)
    H.close(client)
    Expm.Repository.HTTP.Decoder.decode Code.string_to_ast!(body)
  end

  def put(repo, spec) do
    {:ok, 200, _headers, client} = 
      H.request("PUT", "#{repo.url}/#{spec.name}",
                [{"authorization",%b{Basic #{:base64.encode("#{repo.username}:{repo.password}")}}},
                 {"content-type","application/elixir"},
                 ],
                spec.encode, [follow_redirect: true])
    {:ok, body, client} = H.body(client)
    H.close(client)
    Expm.Package.decode body
  end
  
  def list(repo, filter) do
    {:ok, 200, _headers, client} = 
      H.request("PUT", "#{repo.url}",
                [
                 {"content-type","application/elixir"},
                 ],
                filter.encode, [follow_redirect: true])
    {:ok, body, client} = H.body(client)
    H.close(client)
    Expm.Package.decode body
  end

end