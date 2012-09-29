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
           <td><%= inspect value %></td>
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

                Please note that you don't need to signup to get an account. User name and password
                combinations are per package, and this authentication combination gets automatically attached
                to a newly claimed package.
                div>
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