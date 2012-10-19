defrecord Expm.Repository.TermFile, filename: nil

defimpl Expm.Repository, for: Expm.Repository.TermFile do
  alias Expm.Repository.TermFile, as: T

  defmacrop read(filename, [do: block]) do
    quote hygiene: false do
      if File.exists?(unquote(filename)) do
        c = File.read!(unquote(filename))
        packages = Expm.Package.decode(c)      
        unquote(block)
      else
        File.write!(unquote(filename), inspect([]))
      end  
    end
  end

  defmacrop write(filename, [do: block]) do
    quote hygiene: false do
      if File.exists?(unquote(filename)) do
        c = File.read!(unquote(filename))
        packages = Expm.Package.decode(c)      
        unquote(block)
      else
        packages = []
        unquote(block)
      end  
    end
  end

  def get(T[filename: filename], package, version) do
    read(filename) do
      Enum.find(packages, fn(pkg) -> pkg.name == package and pkg.version == version end)
    end
  end

  def versions(T[filename: filename], package) do
    read(filename) do
      packages = Enum.filter(packages, fn(pkg) -> pkg.name == package end)
      Enum.map(packages, Expm.Package.version(&1))
    end
  end

  def put(T[filename: filename], spec) do
    write(filename) do
      packages = [spec|packages]
      File.write(filename, inspect(packages))
    end
    spec
  end

  def delete(T[filename: filename], package, version) do
    write(filename) do
      packages = Enum.filter(packages, fn(pkg) -> pkg.name != package and pkg.version != version end)
      File.write(filename, inspect(packages))
    end
    :ok
  end    
  
  def list(T[filename: filename], filter) do
    match_spec = :ets.match_spec_compile([{filter, [], [:'$_']}])
    read(filename) do
      :ets.match_spec_run(packages, match_spec)
    end
  end

end