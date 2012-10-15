defexception Expm.Package.VersionNotFound, version: nil do
  def message(e) do
    "Version #{inspect e.version} not found"
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

  require EEx
  EEx.function_from_string :def, :file_template,
    %b{Expm.Package.new(name: "<%= @name || "yourlib" %>", description: "<%= @description %>",
                 version: "<%= @version || "0.0.1" %>", keywords: [], 
                 maintainers: [[name: "<%= @author || "Your Name" %>", 
                                email: "<%= @email || "your@email.com" %>"]],
                 repositories: [[github: "user/repo"]])
    }, [:assigns]

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

  def fetch(repo, package) do
    case Enum.reverse(versions(repo, package)) do
     [] -> :not_found
     [top|_] -> fetch(repo, package, top)
    end
  end

  def fetch(repo, package, version) do
    if is_binary(version) and 
       Regex.match?(%r/^[a-z]+.*/i,version) do # symbolic name
      version = binary_to_atom(version) ## FIXME?
    end

    Expm.Repository.get repo, package, version
  end

  def versions(repo, package) do
    List.sort(Expm.Repository.versions repo, package)
  end

  def filter(repo, package) do
    pkgs = 
    Enum.reduce Expm.Repository.list(repo, package),
                [],
                fn(package, acc) ->
                  case :proplists.get_value(package.name, acc, nil) do
                    nil -> [{package.name, package}|acc]
                    another_package ->
                      if another_package.version < package.version do
                         [{package.name, package}|(acc -- [{package.name, another_package}])]
                      else
                         acc
                      end
                  end
                end
    pkgs = lc {_, pkg} inlist pkgs, do: pkg
    pkgs = List.sort pkgs, fn(pkg1, pkg2) -> pkg1.name <= pkg2.name end
  end

  def all(repo) do
    filter repo, Expm.Package[_: :_]
  end

  def search(repo, keyword) do
    pkgs = all(repo)
    re = %r/.*#{keyword}.*/i
    Enum.filter pkgs, fn(pkg) ->
                        Regex.match?(re,pkg.name || "") or
                        Regex.match?(re,pkg.description || "") or
                        Enum.any?(String.split(pkg.keywords, %r(,|\s), global: true),
                                  fn(kwd) -> Regex.match?(re, kwd) end)
                      end
  end

  def delete(repo, package, version) do
    Expm.Repository.delete repo, package, version
  end

  def delete(repo, package) when is_binary(package) do
    results = 
    lc version inlist versions(repo, package) do
      delete(repo, package, version)
    end
    Enum.find(results, :ok, fn(x) -> x != :ok end)
  end

  def delete(repo, package) do
    delete(repo, name(package), version(package))
  end

  def read(file // "package.exs") do
    {:ok, bin} = File.read(file)
    {pkg, _} = Code.eval bin
    pkg
  end

  defdelegate [valid?(package), validate(package)], to: Expm.Package.Validator

  def deps(repo, rec) do
    lc dep inlist dependencies(rec), do: resolve_dep(repo, dep)
  end

  defp resolve_dep(repo, name) when is_binary(name) do
    [version|_] = Enum.reverse(versions(repo, name))
    {name, version}
  end

  defp resolve_dep(_repo, {name, version}) when is_binary(name) and 
                                                (is_binary(version) or is_atom(version)) do
    {name, version}
  end

  defp resolve_dep(repo, {name, [>: version] = v}) when is_binary(name) and 
                                                   (is_binary(version) or is_atom(version)) do
    resolve_dep_impl(repo, name, v, fn(v) -> v > version end)
  end

  defp resolve_dep(repo, {name, [>=: version] = v}) when is_binary(name) and 
                                                    (is_binary(version) or is_atom(version)) do
    resolve_dep_impl(repo, name, v, fn(v) -> v >= version end)
  end

  defp resolve_dep(repo, {name, [<: version] = v}) when is_binary(name) and 
                                                    (is_binary(version) or is_atom(version)) do
    resolve_dep_impl(repo, name, v, fn(v) -> v < version end)
  end

  defp resolve_dep(repo, {name, [<=: version] = v}) when is_binary(name) and 
                                                    (is_binary(version) or is_atom(version)) do
    resolve_dep_impl(repo, name, v, fn(v) -> v <= version end)
  end

  defp resolve_dep_impl(repo, name, version, fun) do
    versions = Enum.reverse(versions(repo, name))
    found = Enum.find(versions, fun)
    unless nil?(found) do
      {name, found}
    else
      raise Expm.Package.VersionNotFound, version: version
    end  
  end
end