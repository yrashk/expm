defrecord Expm.Package, 
  meta: [],
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
  platforms: [],
  directories: ["src","lib","priv","include"] do
  
    @type name :: binary
    @type spec :: list(term)
    @type filter :: spec
    @type version :: term

  import Expm.Utils

  deflist keywords, keyword
  deflist maintainers, maintainer  
  deflist contributors, contributor
  deflist bugs, bug
  deflist licenses, license
  deflist repositories, repository
  deflist dependencies, dependency
  deflist directories, directory
  deflist platforms, platform
end