defmodule Expm do
  use Application.Behaviour
  def start(start_type, start_args) do
    {:ok, m} = :application.get_env(:expm, :app_module)
    m.start(start_type, start_args)
  end

  def start, do: Application.start(:expm)
  
  def start(app_module) do
    :ok = Application.load(:expm)
    :application.set_env(:expm, :app_module, app_module)
    :ok = Application.start(:expm)
  end

  def main(argv) do
    argv = lc arg inlist argv, do: to_binary(arg)
    {opts, commands} = OptionParser.parse(argv, 
                       aliases: [
                                 r: :repository, 
                                ])
    Expm.CLI.new(opts).run(commands)
  end
end