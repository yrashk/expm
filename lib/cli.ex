defrecord Expm.CLI, repository: Expm.Repository.HTTP.new.url, username: nil, password: nil,
                    version: false, format: "asis", format_opts: [] do

  def run([], rec) do
    cond do
      rec.version == true ->
        IO.puts Expm.version
      true ->
        run(nil, rec)
    end
  end

  def run(["server"], rec) do
    cond do
      rec.version == true ->
        IO.puts repo(rec).version
    end
  end

  def run(["list"], rec) do
    run(["search", ""], rec)
  end

  def run(["search", kwd], rec) do
    repo = repo(rec)
    pkgs = Expm.Package.search repo, kwd
    lc pkg inlist pkgs do
      :io.format("~-20ts ~ts~n",[pkg.name, pkg.description])
    end
  end

  def run([<<"spec", field :: binary>>, package], rec) do
    repo = repo(rec)
    pkg = Expm.Package.fetch repo, package
    case pkg do
      :not_found ->
        IO.puts "No such package"
      _ -> 
        IO.puts spec_field(pkg, field, rec)
    end
  end

  def run([<<"spec", field :: binary>>, package, version], rec) do
    repo = repo(rec)
    pkg = Expm.Package.fetch repo, package, version
    case pkg do
      :not_found ->
        IO.puts "No such package"
      _ -> 
        IO.puts spec_field(pkg, field, rec)
    end
  end

  def run(["versions", package], rec) do
    repo = repo(rec)
    lc version inlist Expm.Package.versions(repo, package) do
      IO.puts version
    end
  end

  def run(["publish"], rec) do
    run(["publish", "package.exs"], rec)
  end

  def run(["publish", file], rec) do
    pkg = Expm.Package.read(file)
    IO.inspect pkg.publish(repo(rec))
  end

  def run(_, _) do
    IO.puts "Invalid command"
  end

  defp spec_field(pkg, "", rec), do: do_format(pkg, rec)
  defp spec_field(pkg, <<":", field :: binary>>, _rec) do
   field = binary_to_atom field
   inspect apply(pkg,field,[])
  end

  defp formats, do: [
                     {"mix", Expm.Package.Format.Mix},
                     {"rebar", Expm.Package.Format.Rebar},
                     {"scm", Expm.Package.Format.SCM},
                     {"asis", Expm.Package.Format.Asis},
                    ]
  defp do_format(pkg, rec) do
    format = format(rec)
    {format_opts, _} = Code.eval format_opts(rec)
    formatter = :proplists.get_value(String.downcase(format), formats, Expm.Package.Format.Asis)
    apply(formatter, :to_binary, [apply(formatter,:format, [pkg, format_opts])])
  end

  defp repo(rec) do
     Expm.Repository.HTTP.new(url: repository(rec),
                              username: username(rec), password: password(rec))
  end
end
