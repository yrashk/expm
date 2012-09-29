defmodule Expm.Package.Decoder do
  defexception SecurityException, message: nil
  def decode({ :__block__, _, [b] }) when is_list(b) do
    decode(b)
  end    
  def decode(list) when is_list(list) do
    lc i inlist list, do: decode(i)
  end  
  def decode({:access,l1,[{:__aliases__,l2,[:Expm,:Package]}|rest]}) do
    {:access,l1,[{:__aliases__,l2,[:Expm,:Package]}|decode_1(rest)]}
  end
  def decode(v) do
    raise SecurityException.new(message: "#{Macro.to_binary(v)} is not allowed")  
  end

  defp decode_1({ :{}, b, c }) do
    {:{}, b, decode_1(c) }
  end

  defp decode_1({ _a, _b, _c }=v) do
    raise SecurityException.new(message: "#{Macro.to_binary(v)} is not allowed")
  end

  defp decode_1({ a, b }) do
    { decode_1(a), decode_1(b) }
  end

  defp decode_1(list) when is_list(list) do
    lc i inlist list, do: decode_1(i)
  end

  defp decode_1(other) do
    other
  end
end

defrecord Expm.Package, 
  metadata: [],
  # required
  name: nil,
  description: nil,
  version: nil,
  keywords: [],
  maintainers: [],
  contributors: [],
  bugs: [],
  licenses: [],
  repositories: [],
  dependencies: [],
  # optional
  homepage: nil,
  platforms: [],
  directories: ["src","lib","priv","include"] do

    @type name :: binary
    @type spec :: list(term)
    @type filter :: spec
    @type version :: term

  import Expm.Utils

  deflist keywords, keyword
  deflist maintainers, maintainer  
  deflist contributors, contributor
  deflist bugs, bug
  deflist licenses, license
  deflist repositories, repository
  deflist dependencies, dependency
  deflist directories, directory
  deflist platforms, platform

  def encode(rec) do
    inspect(rec)
  end

  def decode(text) do
    ast = Code.string_to_ast! text
    {v, _} = Code.eval_quoted Expm.Package.Decoder.decode(ast)
    v
  end

  def publish(repo, package) do
    Expm.Repository.put repo, package
  end

  def fetch(repo, package, version) do
    Expm.Repository.get repo, package, version
  end

  def versions(repo, package) do
    Expm.Repository.versions repo, package
  end

  def filter(repo, package) do
    Expm.Repository.list repo, package
  end

  def all(repo) do
    Expm.Repository.list repo, Expm.Package[_: :_]
  end

end