defrecord Expm.Repository.Mirror, source: nil, destination: nil, frequency: 1000*60, timer: nil do
  defoverridable new: 1
  def new(opts) do
    rec = super(opts)
    :timer.apply_interval(frequency(rec), __MODULE__, :update, [rec])
    rec
  end

  def cancel(rec) do
    :timer.cancel(timer(rec))
  end

  def update(rec) do
    pkgs = Expm.Package.all source(rec)
    lc pkg inlist pkgs, do: Expm.Package.publish destination(rec), pkg
  end
end

defimpl Expm.Repository, for: Expm.Repository.Mirror do
  
  def get(repo, package, version) do
    Expm.Repository.get repo.destination, package, version
  end

  def versions(repo, package) do
    Expm.Repository.versions repo.destination, package
  end

  def put(repo, spec) do
    Expm.Repository.puts repo.destination, spec
  end
  
  def list(repo, filter) do
    Expm.Repository.list repo.destination, filter
  end
end
