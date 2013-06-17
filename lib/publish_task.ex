defmodule Mix.Tasks.Publish do
  use Mix.Task

  @shortdoc """
  Publish your project on expm.
  """

  @moduledoc """
  Publish your project on expm.

  ## Options

  `--repository url`

  By default, this is [https://expm.co/](https://expm.co/)

  `--username USER` and `--password PASSWORD`

  If not available, uses config file.
  """

  # Get the repo - finding authentication from config file
  # if not available elsewhere.
  defp get_repo(opts) do
    url = opts[:repository] || "https://expm.co"
    Expm.Repository.HTTP.new(url: url,
        username: opts[:username], password: opts[:password])
  end

  # Update options based on the configuration file
  defp read_config(opts) do
    config_opts = [:username, :password]
    update_config(opts, config_opts)
  end

  defp update_config(opts, []), do: opts
  defp update_config(opts, [key|t]) do
    if opts[key] == nil do
      opts = Keyword.put opts, key, Expm.UserConfig.get key
    end
    update_config(opts, t)
  end

  def run(args) do
    { opts, [] } = OptionParser.parse(args)
    opts = read_config(opts)
    Application.Behaviour.start :expm
    publish get_repo(opts)
  end

  def publish(repo) do
    proj = Mix.project
    package = Expm.Package.new(name: atom_to_binary(proj[:app]),
                               version: proj[:version],
                               description: proj[:description],
                               keywords: proj[:keywords],
                               maintainers: proj[:maintainers],
                               repositories: proj[:repositories]
                              )
    Expm.Package.publish repo, package
  end
end
