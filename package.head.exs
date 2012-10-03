Expm.Package.new(name: "expm", description: "Elixir package manager",
                 version: :head, keywords: ["Elixir","Erlang","package","library","dependency","dependencies"], 
                 maintainers: [[name: "Yurii Rashkovskii", email: "yrashk@gmail.com"]],
                 repositories: [[github: "yrashk/expm"]],
                 dependencies: [{"validatex", :head},
                                "mimetypes",
                                "genx",
                                "exreloader",
                                "hackney"])
