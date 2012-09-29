defrecord Expm.CLI, repository: "http://expm.co", username: nil, password: nil do

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

  def run(["spec",package], rec) do
    repo = repo(rec)
    case Enum.reverse(List.sort(Expm.Package.versions repo, package)) do 
      [] -> 
        IO.puts "No such package"
      [version] -> 
        pkg = Expm.Package.fetch repo, package, version
        IO.inspect pkg
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

  defp repo(rec) do
     Expm.Repository.HTTP.new(url: repository(rec),
                              username: username(rec), password: password(rec))
  end
end
