defmodule Expm.Package.Validator do
  alias Validatex, as: V

  def validation(package) do
    [
      {:name, package.name, V.Format.new(re: %r/^([a-z]|_|-|[0-9])+$/i)},
      {:description, package.description, V.Format.new(re: %r/.*/i, allow_nil: true, allow_empty: true)},
      {:version, package.version, V.Union.new(options: [V.Type.new(is: :atom, allow_nil: false, allow_undefined: false),
                                                        V.Format.new(re: %r/([0-9])(([0-9]\.)*(-.+)?)?/i)])},
      {:keywords, package.keywords, V.Type.new(is: :list)},
      {:maintainers, package.maintainers, V.Type.new(is: :list)},
      {:maintainers, package.maintainers, V.Length.new(is: V.Range.new(from: 1))},
      {:contributors, package.maintainers, V.Type.new(is: :list)},
      {:homepage, package.homepage, V.Type.new(is: :string, allow_nil: true)},
      {:directories, package.directories, V.Type.new(is: :list)},
      {:repositories, package.repositories, V.Type.new(is: :list)},
      {:repositories, package.repositories, V.Length.new(is: V.Range.new(from: 1))},      
    ] ++
    lc keyword inlist package.keywords do
      {{:keyword, keyword}, keyword, V.Neg.new(message: :disallowed_characters, validation: V.Format.new(re: %r/[\s,]+/i))}
    end ++
    lc directory inlist package.directories do
      {{:directory, directory}, directory, V.Type.new(is: :string)}
    end ++    
    List.flatten(
      lc maintainer inlist package.maintainers do
        person_validation(:maintainer, maintainer)
      end) ++
    List.flatten(
      lc contributor inlist package.contributors do
        person_validation(:contributor, contributor)
      end) ++  
    List.flatten(
    lc repository inlist package.repositories do
      [
       {{:repository, repository, :type}, repository[:github] || repository[:git], V.Neg.new(validation: nil, message: :scm_type_required)},
      ] ++
      if repository[:github] do
       [{{:repository, repository, :github}, repository[:github], V.Format.new(re: "[a-z0-9_-]+/[a-z0-9_-]+", allow_nil: true, allow_empty: true)}]
      else
       []
      end ++
      if repository[:git] do      
       [{{:repository, repository, :git}, repository[:git], V.Format.new(re: ".+", allow_nil: true, allow_empty: true)}]
      else
       []
      end 
    end)
  end

  def validate(package) do
    V.validate(validation(package))
  end

  def valid?(package) do
    validate(package) == []
  end

  defp person_validation(t, v) do
    [
      {{t, v}, v[:name], V.Length.new(is: V.Range.new(from: 1))},
      {{t, v}, v[:name], V.Type.new(is: :string)},
      {{t, v}, v[:email],V.Type.new(is: :string, allow_nil: true)},
    ]
  end
end