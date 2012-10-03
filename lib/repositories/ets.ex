defrecord Expm.Repository.ETS, tid: nil, options: [:ordered_set, :public] do
  defoverridable [new: 0]
  def new do
    repo = super()
    repo.tid(init(repo))
  end

  defp init(repo) do
    :ets.new(__MODULE__, options(repo))
  end
end

defimpl Expm.Repository, for: Expm.Repository.ETS do
  alias :ets, as: ETS

  def get(repo, package, version) do
    case ETS.lookup(repo.tid, {package, version}) do
      [{{^package, ^version}, spec}] -> spec
      _ -> :not_found
    end
  end

  def versions(repo, package) do
    objects = ETS.match_object(repo.tid, {{package, :_}, :_})
    lc {{_name, version}, _spec} inlist objects, do: version
  end

  def put(repo, spec) do
    ETS.insert(repo.tid, {{spec.name, spec.version}, spec})
    spec
  end

  def delete(repo, package, version) do
    ETS.delete(repo.table, {package, version})
    :ok
  end    
  
  def list(repo, filter) do
    lc {_key, spec} inlist ETS.match_object(repo.tid, {:_, filter}), do: spec
  end
end