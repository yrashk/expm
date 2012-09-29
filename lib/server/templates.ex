defmodule Expm.Server.Templates.Package do
  require EEx

  EEx.function_from_string :def, :description,
    %b{
      <%= description %>
    }, [:description]

  EEx.function_from_string :def, :directories,
    %b{
      <%= lc dir inlist directories do %>
        <span class="label"><%= dir %></span>
      <% end %>
    }, [:directories]

  EEx.function_from_string :def, :homepage,
    %b{
      <%= if nil?(homepage) do %>
      <% else %>
        <a href="<%= homepage %>"><%= homepage %></a>
      <% end %>
    }, [:homepage]

  EEx.function_from_string :def, :keywords,
    %b{
      <%= lc keyword inlist keywords do %>
        <span class="label label-info"><%= keyword %></span>
      <% end %>
    }, [:keywords]

  EEx.function_from_string :def, :metadata,
    %b{
      <%= lc \{tag, value \} inlist metadata do %>
        <span class="label label-info"><%= tag %>:</span> <%= inspect value %>
      <% end %>
    }, [:metadata]

  EEx.function_from_string :def, :name,
    %b{
      <strong><%= name %></strong>
    }, [:name]

  EEx.function_from_string :def, :repositories,
    %b{
      <%= lc repository inlist repositories do %>
        <%= if repository[:github] do %>
          <span class="label label-important">GitHub</span>
          <a href="https://github.com/<%= repository[:github] %>"><%= repository[:github] %></a>
        <%  end %>
        <%= if repository[:git] do %>
          <span class="label label-important">Git</span>
          <a href="<%= repository[:git] %>"><%= repository[:git] %></a>
        <%  end %>        
        <%= if repository[:git] do %>
          <span class="label label-important">Git</span>
          <a href="<%= repository[:git] %>"><%= repository[:git] %></a>
        <%  end %>
        <%= if repository[:url] do %>
          <span class="label label-important">URL</span>
          <a href="<%= repository[:url] %>"><%= repository[:url] %></a>
        <%  end %>
      <% end %>
    }, [:repositories]


  EEx.function_from_string :def, :version,
    %b{
      <%= version %>
    }, [:version]

  def maintainers(maintainers), do: people(maintainers)
  def contributors(contributors), do: people(contributors)

  EEx.function_from_string :defp, :people,
    %b{
      <%= lc person inlist people do %>
        <span class="label label-success"><%= person[:name] %> &lt;<%= person[:email] %>&gt;</span>
      <% end %>
    }, [:people]


  def render(field, value) do
    if function_exported?(__MODULE__, field, 1) do
      apply(__MODULE__, field, [value])
    else
      inspect value
    end
  end

end

defmodule Expm.Server.Templates do
  require EEx

  EEx.function_from_string :def, :list,
    %b{
          <h1><%= title %> (<%= length(pkgs) %>)</h1>
          <table class="table table-striped table-hover">
           <tbody>
           <%= lc pkg inlist pkgs do %>
             <tr>
             <td><a href="<%= pkg.name %>"><%= pkg.name %></a></td>
             <td><%= pkg.description %></td>
             </tr>
           <% end %>
           </tbody>
          </table>
      }, [:pkgs, :title]

  EEx.function_from_string :def, :package,
    %b{
     <ul class="breadcrumb">
       <li><a href="/<%= package.name %>"><%= package.name %></a> <span class="divider"> :: </span></li>       
       <%= lc version inlist Expm.Package.versions(repo, package.name) do %>
        <%= if version == package.version do %>
          <li class="active"><%= package.version %><span class="divider">|</span></li>       
        <% else %>
          <li><a href="/<%= package.name %>/<%= version %>"><%= version %></a> <span class="divider">|</span></li>       
        <% end %>          
       <% end %>
     </ul>
     <h1> <%= package.name %> (<%= package.version %>) </h1>
     <h4> <%= package.description %> </h4>
     <table class="table table-bordered table-striped">
      <thead>
      <tr>
        <th>Field</th>
        <th>Value</th>
      </tr>
      </thead>
      <tbody>
      <%= lc \{field, value\} inlist package.to_keywords do %>
         <tr>
           <td><b><%= to_binary field %></b></td>
           <td><%= Expm.Server.Templates.Package.render(field,value) %></td>
         </tr>
      <% end %>
      </tbody>
     </table>
     <h4>package.exs:</h4>
     <pre><%= inspect package %></pre>
    },[:package, :repo]

  EEx.function_from_string :def, :page,
    %b{

      <!DOCTYPE html>
      <html>
        <head>
          <title>EXPM</title>
          <!-- Bootstrap -->
          <link href="/s/css/bootstrap.min.css" rel="stylesheet">
        </head>
        <body>

         <div class="navbar navbar-inverse navbar-fixed-top">
              <div class="navbar-inner">
                <div class="container">
                  <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
                  </a>
                  <a class="brand" href="/">EXPM</a>
                  <div class="nav-collapse collapse">
                    <ul class="nav">
                      <li>
                        <form action="/" method="GET" class="navbar-search pull-left">  
                          <input type="text" name="q" class="search-query" placeholder="Search">  
                        </form>                        
                      </li>
                    </ul>
                  </div><!--/.nav-collapse -->
                </div>
              </div>
            </div>        
            <a href="https://github.com/yrashk/expm"><img style="position: absolute; top: 0; right: 0; border: 0; z-index: 999999999" src="https://s3.amazonaws.com/github/ribbons/forkme_right_orange_ff7600.png" alt="Fork me on GitHub"></a>

            <div class="container">
              <div class="well hero-unit">
                <h1><%= Application.environment(:expm)[:site_title] %></h1>
                <div><%= Application.environment(:expm)[:site_subtitle] %></div>
                <p>
                  <%= @motd %>
                </p>
              </div>
              <div class="row">
                <%= content %>
              </div>
              <hr>

              <div class="row well" style="margin-top: 40px">
                <p>This repository is available over HTTP:</p>
                   
                <p>
                  <code>expm -r http://<%= @host %><%= @port %> list</code>
                </p>
                <p>To publish a package:</p>

                <p><code>expm --username ... --password ... -r http://<%= @host %><%= @port %> publish [package.exs]</code></p>

                <p>
                Please note that you don't need to signup to get an account. User name and password
                combinations are per package, and this authentication combination gets automatically attached
                to a newly claimed package.
              </div>
              <hr>

              <div class="row">
                <center><small>Running expm <%= \{:ok, vsn\} = :application.get_key(:expm, :vsn) ; vsn %> on Elixir 
                <%= System.version %> (<%= \{_, sha, _\} = System.build_info ; sha %>)
                </small></center>
              </div>
            </div>


          <script src="http://code.jquery.com/jquery-latest.js"></script>
          <script src="/s/js/bootstrap.min.js"></script>
        </body>
      </html>
    }, [:content, :assigns]


  
end