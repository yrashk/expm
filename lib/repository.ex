defprotocol Expm.Repository do
  @only [Record]
  @type t :: term

  @spec get(t, Expm.Package.name, Expm.Package.version), do: 
        Expm.Package.spec | :not_found
  def get(repo, package, version)

  @spec versions(t, Expm.Package.name), do: list(Expm.Package.version)
  def versions(repo, package)

  @spec put(t, Expm.Package.spec), do: :ok
  def put(repo, spec)

  @spec delete(t, Expm.Package.name, Expm.Package.version), do: :ok | {:error, atom}
  def delete(repo, package, version)

  @spec list(t, Expm.Package.filter), do: list(Expm.Package.spec)
  def list(repo, filter)
end