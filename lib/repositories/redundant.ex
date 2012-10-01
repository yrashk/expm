defrecord Expm.Repository.Redundant, repositories: []
defimpl Expm.Repository, for: Expm.Repository.Redundant do
  
  def get(repo, package, version) do
    Enum.reduce(repo.repositories, :not_found,
                function do
                  repository, :not_found -> 
                    Expm.Repository.get repository, package, version
                  _repository, result -> result
                end)
  end

  def versions(repo, package) do
    Enum.reduce(repo.repositories, [],
                function do
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
  
  def list(repo, filter) do
    List.uniq(Enum.reduce(repo.repositories, [],
                fn(repository, acc) ->
                  Expm.Repository.list(repository, filter) ++ acc
                end))
  end
end
