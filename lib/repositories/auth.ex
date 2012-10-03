defrecord Expm.Repository.Auth, username: nil, auth_token: nil, repository: nil,
                                cmp: nil, transform: nil do

  defoverridable new: 1

  def new(opts) do
    rec = super(opts)                                
    rec = rec.cmp(function(__MODULE__, :bcrypt_cmp, 2))
    rec.transform(function(__MODULE__, :bcrypt_transform, 1))
  end

  def published_by(repo), do: {repo.username, repo.auth_token}

  def bcrypt_cmp({k, {:bcrypt, h}}, {k, v2}) do
    :erlpass.match(v2, h)
  end
  def bcrypt_cmp({_, {:bcrypt, _}}, {_, _}), do: false
  def bcrypt_cmp({k, v1}, {k, v2}) do
   v2 = :crypto.hash(:sha256, v2)
   v1 == v2
  end
  def bcrypt_cmp(_, _), do: false

  def bcrypt_transform({k, v}) do
    {k, {:bcrypt, :erlpass.hash(v)}}
  end

end

defimpl Expm.Repository, for: Expm.Repository.Auth do

  def get(repo, package, version) do
    strip_auth_token Expm.Repository.get(repo.repository, package, version)
  end

  def versions(repo, package) do
    lc version inlist Expm.Repository.versions(repo.repository, package), do: version
  end

  def put(repo, spec) do
    unless authorized?(repo, spec.name) do
      {:error, :access_denied}    
    else
      spec = Expm.Repository.put repo.repository, 
                                 spec.metadata(Keyword.put spec.metadata, 
                                 :published_by, repo.transform.(Expm.Repository.Auth.published_by(repo)))
      strip_auth_token(spec)                                 
    end
  end

  def delete(repo, package, version) do
    unless authorized?(repo, package) do
      {:error, :access_denied}    
    else
      Expm.Repository.delete repo.repository, package, version
    end
  end
  
  def list(repo, filter) do
    lc spec inlist Expm.Repository.list(repo.repository, filter), do: strip_auth_token(spec)
  end

  defp authorized?(repo, package) do
    if nil?(repo.username) or nil?(repo.auth_token) or
       repo.username == "" or repo.auth_token == "" do
      false
    else
      pkgs = Expm.Repository.list(repo.repository, Expm.Package[name: package, _: :_])
      published_by = Expm.Repository.Auth.published_by(repo)
      pkgs == [] or   Enum.any?(pkgs, fn(pkg) ->    
                                    repo.cmp.(pkg.metadata[:published_by], published_by) or
                                    nil?(pkg.metadata[:published_by]) or
                                    not is_tuple(pkg.metadata[:published_by])
                      end)
    end  
  end

  defp strip_auth_token(:not_found), do: :not_found
  defp strip_auth_token(spec) do
    if (published_by = spec.metadata[:published_by]) do
      case published_by do
        {username, _} ->
          spec.metadata(Keyword.put spec.metadata, :published_by, username)
        _ ->
          spec
      end
    else
      spec
    end 
  end
end