defmodule Expm do

  defmacro __using__(opts) do
    http_repo = if opts[:url], do: Expm.Repository.HTTP.new(url: opts[:url]), else: Expm.Repository.HTTP.new
    repo = opts[:repository] || http_repo
    format = opts[:format] || Expm.Package.Format.Mix
    quoted_repo = Macro.escape repo
    quote do
      def expm(package, options // []) do
        repo = options[:repository] || unquote(quoted_repo)
        format = options[:format] || unquote(format)
        pkg = 
        if options[:version] do
          Expm.Package.fetch repo, package, options[:version]
        else
          Expm.Package.fetch repo, package
        end
        format.format pkg, (options[format] || [])
      end      
    end
  end

  @version Mix.project[:version]
  def version do
    @version
  end

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
    :ok = Application.start :ssl
    argv = lc arg inlist argv, do: to_binary(arg)
    {opts, commands} = OptionParser.parse(argv, 
                       aliases: [
                                 r: :repository, 
                                ],
                       flags: [:all])
    opts = Keyword.merge Expm.UserConfig.read, opts        
    Expm.CLI.new(opts).run(commands)
  end
end