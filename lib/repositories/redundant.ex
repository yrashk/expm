defrecord Expm.Repository.Redundant, repositories: []
defimpl Expm.Repository, for: Expm.Repository.Redundant do
  
  def get(repo, package, version) do
    Enum.reduce(repo.repositories, :not_found,
                fn
                  repository, :not_found -> 
                    Expm.Repository.get repository, package, version
                  _repository, result -> result
                end)
  end

  def versions(repo, package) do
    Enum.reduce(repo.repositories, [],
                fn
                  repository, [] -> 
                    Expm.Repository.versions repository, package
                  _repository, result -> result
                end)
  end

  def put(repo, spec) do
    Enum.reduce(repo.repositories, spec,
                fn(repository, spec) ->
                  Expm.Repository.put repository, spec
                end)
  end

  def delete(repo, package, version) do
    Enum.reduce(repo.repositories, :ok,
                fn(repository, _) ->
                  Expm.Repository.delete repository, package, version
                end)
  end
  
  def list(repo, filter) do
    List.uniq(Enum.reduce(repo.repositories, [],
                fn(repository, acc) ->
                  Expm.Repository.list(repository, filter) ++ acc
                end))
  end
end
