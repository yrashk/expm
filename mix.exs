Code.append_path "deps/relex/ebin"

defmodule Expm.Mixfile do
  use Mix.Project

  def project do
    [ app: :expm,
      version: String.strip(System.cmd("git describe --always --tags"),?\n),
      deps: deps,
      escript_embed_elixir: true,
      release_options: [path: "rel"]
    ]
  end

  # Configuration for the OTP application
  def application do
      [applications: [:lager, :lagerex, :hackney, :ranch, :cowboy, :mimetypes, :inets,
                      :genx, :crypto, :exreloader, :erlpass],
       mod: {Expm, []}]
  end

  defp deps do
    [
      {:validatex, %r(.*), github: "yrashk/validatex"},
      {:hackney, %r(.*), github: "benoitc/hackney"},
      {:mimetypes, %r(.*), github: "spawngrid/mimetypes"},
      {:edown, %r(.*), github: "esl/edown"},
      {:genx, %r(.*), github: "yrashk/genx"},
      {:ranch, %r(.*), github: "extend/ranch"},
      {:cowboy, %r(.*), github: "extend/cowboy"},
      {:lagerex, %r(.*), github: "yrashk/lagerex"},
      {:exreloader, %r(.*), github: "yrashk/exreloader"},
      {:erlpass, %r(.*), github: "yrashk/erlpass", branch: "patch-1", compile: "rebar compile deps_dir=.."},
        {:proper, %r(.*),github: "manopapad/proper"},
        {:bcrypt, %r(.*), github: "spawngrid/erlang-bcrypt"},
      {:relex, github: "yrashk/relex"},
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
