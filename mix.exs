Code.append_path "deps/relex/ebin"

defmodule Expm.Mixfile do
  use Mix.Project

  def project do
    [ app: :expm,
      version: String.strip(System.cmd("git describe --always --tags"),?\n),
      deps: deps,
      escript_embed_elixir: true,
      escript_app: nil, # don't start expm app
      release_options: [path: "rel"]
    ]
  end

  # Configuration for the OTP application
  def application do
      [applications: [:lager, :lagerex, :hackney, :ranch, :cowboy, :mimetypes, :inets,
                      :genx, :crypto, :exreloader, :erlpass, :exconfig],
       mod: {Expm, []}]
  end

  defp deps do
    [
      {:validatex, github: "yrashk/validatex"},
      {:hackney, github: "benoitc/hackney"},
      {:genx, github: "yrashk/genx", override: true},
      {:cowboy, github: "extend/cowboy"},
      {:lagerex, github: "cthulhuology/lagerex"},
      {:exreloader, github: "yrashk/exreloader"},
      {:erlpass, github: "ferd/erlpass"},
        {:bcrypt, github: "spawngrid/erlang-bcrypt", override: true},
      {:relex, github: "yrashk/relex"},
      {:exconfig, github: "yrashk/exconfig"},
    ]
  end

  if Code.ensure_loaded?(Relex.Release) do
    defmodule Release do
      use Relex.Release

      def name, do: "expm"
      def version, do: Mix.project[:version]
      def applications, do: [:expm]
      def lib_dirs, do: ["deps"]
    end
  end
end
