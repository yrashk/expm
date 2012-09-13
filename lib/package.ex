defrecord Expm.Package, 
  # required
  name: nil,
  description: nil,
  version: nil,
  keywords: [],
  maintainers: [],
  contributors: [],
  bugs: [],
  licenses: [],
  repositories: [],
  dependencies: [],
  # optional
  homepage: nil,
  os: [],
  cpu: [],
  directories: ["src","lib","priv","include"] do
    @type name :: binary
    @type spec :: list(term)
    @type filter :: spec
    @type version :: term
end