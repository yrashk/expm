defprotocol Expm.Repository do
  @only [Record]

  @spec get(t, Expm.Package.name, Expm.Package.version) :: 
        Expm.Package.spec | :not_found
  def get(repo, package, version)

  @spec versions(t, Expm.Package.name) :: list(Expm.Package.version)
  def versions(repo, package)

  @spec put(t, Expm.Package.spec) :: :ok
  def put(repo, spec)

  @spec delete(t, Expm.Package.name, Expm.Package.version) :: :ok | {:error, atom}
  def delete(repo, package, version)

  @spec list(t, Expm.Package.filter) :: list(Expm.Package.spec)
  def list(repo, filter)
end
