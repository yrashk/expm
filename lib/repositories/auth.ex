defrecord Expm.Repository.Auth, username: nil, auth_token: nil, repository: nil

defimpl Expm.Repository, for: Expm.Repository.Auth do

  def get(repo, package, version) do
    strip_auth_token Expm.Repository.get(repo.repository, package, version)
  end

  def versions(repo, package) do
    lc version inlist Expm.Repository.versions(repo.repository, package), do: version
  end

  def put(repo, spec) do
    pkgs = Expm.Repository.list(repo.repository, Expm.Package[name: spec.name, _: :_])
    published_by = {repo.username, repo.auth_token}
    if Enum.all?(pkgs, fn(pkg) -> pkg.metadata[:published_by] == published_by end) do
      spec = Expm.Repository.put repo.repository, 
                                 spec.metadata(Keyword.put spec.metadata, :published_by, published_by)
      strip_auth_token(spec)                                 
    else
      {:error, :access_denied}
    end
  end
  
  def list(repo, filter) do
    lc spec inlist Expm.Repository.list(repo.repository, filter), do: strip_auth_token(spec)
  end

  defp strip_auth_token(spec) do
    if (published_by = spec.metadata[:published_by]) do
      {username, _} = published_by
      spec.metadata(Keyword.put spec.metadata, :published_by, username)
    else
      spec
    end 
  end
end