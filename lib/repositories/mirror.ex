defrecord Expm.Repository.Mirror, source: nil, destination: nil, frequency: 1000*60, timer: nil do
  defoverridable new: 1
  def new(opts) do
    rec = super(opts)
    {:ok, tref } = :timer.apply_interval(frequency(rec), __MODULE__, :update, [rec])
    timer(tref, rec)
  end

  def cancel(rec) do
    :timer.cancel(timer(rec))
  end

  def update(rec) do
    src = source(rec)
    pkgs = Expm.Package.all src
    lc pkg inlist pkgs, version inlist Expm.Package.versions(src, pkg.name) do
      package = Expm.Package.fetch source(rec), pkg.name, version
      Expm.Package.publish destination(rec), package
    end
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
    Expm.Repository.put repo.destination, spec
  end
  
  def list(repo, filter) do
    Expm.Repository.list repo.destination, filter
  end
end
