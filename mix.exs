defmodule Expm.Mixfile do
  use Mix.Project

  def project do
    [ app: :expm,
      version: "0.0.1",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  defp deps do
    []
  end
end
