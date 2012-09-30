defmodule Expm.Package.Format.Mix do
  def format(pkg, options) do
    {options[:app] || binary_to_atom(pkg.name),
     options[:vsn] || %r(.*),
     hd(pkg.repositories)
    }
  end

  def to_binary(x), do: inspect(x)
end

defmodule Expm.Package.Format.Rebar do
  def format(pkg, options) do
    r = hd(pkg.repositories)
    {options[:app] || binary_to_atom(pkg.name),
     options[:vsn] || '.*',
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