defmodule Expm.Package.Format.Mix do
  def format(pkg, options) do
    {options[:app] || binary_to_atom(pkg.name),
     options[:vsn] || %r(.*),
     hd(pkg.repositories)
    }
  end
end

defmodule Expm.Package.Format.Asis do
  def format(pkg, _options) do
    pkg
  end
end