defmodule Expm.Package.Format.Mix do
  def format(pkg, options) do
    {options[:app] || binary_to_atom(pkg.name),
     (if is_binary(pkg.version), do: pkg.version, else: options[:vsn] || %r(.*)),
     hd(pkg.repositories)
    }
  end

  # Remove the additional [] around the options, so
  #
  #  { :erlpass, github: "ferd/erlpass", compile: "rebar compile deps_dir=.." }
  #
  # is converted to something that looks identical, and not
  #
  #  { :erlpass, [ github: "ferd/erlpass", compile: "rebar compile deps_dir=.." ] }
  #
  def to_binary(spec = {name, options})
  when is_atom(name) and is_list(options) do
    if Enum.all?(options, is_tuple(&1)) do
      "{ " <>
      [ inspect(name), kw_list_contents(options) ] 
        |> List.flatten
        |> Enum.join(", ")
      <> " }"
    else
      inspect(spec)
    end
  end
  def to_binary(x), do: inspect(x)

  defp kw_list_contents([]), do: []
  defp kw_list_contents([{k,v}|t]) do
    [ "#{k}: #{inspect(v)}" | kw_list_contents(t) ]
  end

end

defmodule Expm.Package.Format.Rebar do
  def format(pkg, options) do
    r = hd(pkg.repositories)
    {options[:app] || binary_to_atom(pkg.name),
     (if is_binary(pkg.version), do: to_char_list(pkg.version), else: options[:vsn] || '.*'),     
     repo(r)
    }
  end

  defp repo(r) do
    cond do
     not nil?(r[:github]) ->
       {:git, %c(https://github.com/#{r[:github]}), git_object(r)}
     not nil?(r[:git]) ->
       {:git, %c(r[:git]), git_object(r)}       
    end   
  end

  defp git_object(r) do
     cond do
      r[:branch] -> {:branch, to_char_list(r[:branch])}
      r[:tag] -> {:tag, to_char_list(r[:tag])}
      true -> {:branch, 'master'}
     end  
  end

  def to_binary(x), do: :io_lib.format("~p",[x])
end

defmodule Expm.Package.Format.SCM do
  def format(pkg, options) do
    r = hd(pkg.repositories)
    command = options[:command] || :checkout
    scm(command, pkg.name, scm_system(r))
  end

  defp scm(:checkout, name, {:git, r}) do
    ref = r[:branch] || r[:tag]
    "git clone #{r[:git]} #{name} && cd #{name}" <>
     (if ref, do: " && git checkout #{ref}", else: "")
  end

  defp scm_system(r) do
    cond do
      r[:github] -> {:git, Keyword.put(r, :git, "https://github.com/#{r[:github]}")}
      r[:git] -> {:git, r}
    end
  end

  def to_binary(x), do: x
end


defmodule Expm.Package.Format.Asis do
  def format(pkg, _options) do
    pkg
  end
  def to_binary(x), do: inspect(x)  
end