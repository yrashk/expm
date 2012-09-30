defmodule Expm.Mixfile do
  use Mix.Project

  def project do
    [ app: :expm,
      version: String.strip(System.cmd("git describe --always --tags"),?\n),
      deps: deps,
      escript_embed_elixir: true
    ]
  end

  # Configuration for the OTP application
  def application do
      [applications: [:lager, :lagerex, :hackney, :ranch, :cowboy, :genx, :crypto],
       mod: {Expm, []}]
  end

  defp deps do
    [
      {:hackney, %r(.*), github: "benoitc/hackney"},
      {:mimetypes, %r(.*), github: "spawngrid/mimetypes"},
      {:edown, %r(.*), github: "esl/edown"},
      {:genx, %r(.*), github: "yrashk/genx"},
      {:ranch, %r(.*), github: "extend/ranch"},
      {:cowboy, %r(.*), github: "extend/cowboy"},
      {:lagerex, %r(.*), github: "yrashk/lagerex"},
    ]
  end
end
