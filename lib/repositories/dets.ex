defrecord Expm.Repository.DETS, table: nil,
                                filename: "expm.dat",
                                options: [auto_save: 1000] do
  defoverridable [new: 1]
  def new(opts) do
    super(opts) /> init
  end

  defp init(repo) do
    ref = make_ref
    :dets.open_file(ref, repo.options /> Keyword.put(:file, binary_to_list(repo.filename)))
    repo.table(ref)
  end
end

defimpl Expm.Repository, for: Expm.Repository.DETS do
  alias :dets, as: DETS

  def get(repo, package, version) do
    case DETS.lookup(repo.table, {package, version}) do
      [{{^package, ^version}, spec}] -> spec
      _ -> :not_found
    end
  end

  def versions(repo, package) do
    objects = DETS.match_object(repo.table, {{package, :_}, :_})
    lc {{_name, version}, _spec} inlist objects, do: version
  end

  def put(repo, spec) do
    DETS.insert(repo.table, {{spec.name, spec.version}, spec})
    spec
  end
  
  def list(repo, filter) do
    lc {_key, spec} inlist DETS.match_object(repo.table, {:_, filter}), do: spec
  end
end