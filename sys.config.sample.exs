[expm:
  [app_module: Expm.Server,
   http_port: 8080,
   site_title: "Elixir Packages",
   site_subtitle: %b{<small>A repository for publishing <a href="http://elixir-lang.org">Elixir</a> & <a href="http://erlang.org">Erlang</a> packages</small>},
   repository: quote do: Expm.Repository.DETS.new(filename: "expm.dat")],
 lager:
   [handlers: [
     {:lager_console_backend, :info},
     {:lager_file_backend, [
        {'log/debug.log', :debug, 10485760, '$D0', 5},
        {'log/error.log', :error, 10485760, '$D0', 5},
        {'log/console.log', :info, 10485760, '$D0', 5},
      ]
     }
    ],
    error_logger_redirect: true
   ],
  kernel: [error_logger: false],
  sasl: [sasl_error_logger: false]]