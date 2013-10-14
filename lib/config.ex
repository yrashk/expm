defmodule Expm.Config do
  use ExConfig.Object

  defproperty http_port, default: 8080
  defproperty site_title, default: "Elixir Packages"
  defproperty site_subtitle, default: %s{<small>A repository for publishing <a href="http://elixir-lang.org">Elixir</a> & <a href="http://erlang.org">Erlang</a> packages</small>}
  defproperty repository  
  defproperty package_footer

  defproperty log_dir, default: "log"

  def sys_config(config) do   
    [
     expm: [
       app_module: Expm.Server,
       site_title: config.site_title,
       site_subtitle: config.site_subtitle,
       repository: config.repository,
       http_port: config.http_port,
       package_footer: config.package_footer
     ],
     lager:
       [handlers: [
         {:lager_console_backend, :info},
         {:lager_file_backend, [
            {to_char_list(Path.join(config.log_dir, "debug.log")), :debug, 10485760, '$D0', 5},
            {to_char_list(Path.join(config.log_dir, "error.log")), :error, 10485760, '$D0', 5},
            {to_char_list(Path.join(config.log_dir, "console.log")), :info, 10485760, '$D0', 5},
          ]
         }
        ],
        error_logger_redirect: true
       ],
      kernel: [error_logger: false],
      sasl: [sasl_error_logger: false]     
    ]
  end

  def sys_config!(filename, config) do
    File.write!(filename, :io_lib.format("~p.~n",[sys_config(config)]))
  end
end
