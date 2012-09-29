defmodule Expm.Server.Templates do
  require EEx
  EEx.function_from_string :def, :package,
    %b{
     <table border="1">
      <tr>
        <th>Field</th>
        <th>Value</th>
      </tr>
      <%= lc \{field, value\} inlist package.to_keywords do %>
         <tr>
           <td><b><%= to_binary field %></b></td>
           <td><%= inspect value %></td>
         </tr>
      <% end %>
     </table>
     <h4>package.exs:</h4>
     <code><%= inspect package %></code>
    },[:package]

  EEx.function_from_string :def, :page,
    %b{
      <a href="https://github.com/yrashk/expm"><img style="position: absolute; top: 0; right: 0; border: 0;" src="https://s3.amazonaws.com/github/ribbons/forkme_right_orange_ff7600.png" alt="Fork me on GitHub"></a>    
      <h1>EXPM Repository</h1>
      <p><small>(<a href="http://elixir-lang.org">Elixir</a> and <a href="http://erlang.org">Erlang</a> packages)</small></p>
      <p><%= @motd %></p>
      <hr />
      <%= content %>
      <p />
      <hr />
      <p>This repository is available over HTTP:</p>
         
      <code>repo = Expm.Repository.HTTP.new url: "http://<%= @host %><%= @port %>"[, username: "...", password: "..."]</code>

      <p>To publish a package:</p>

      <code>Expm.Package.publish repo, Expm.Package.read</code> (will read package.exs)
      <p>or</p>
      <code>Expm.Package.publish repo, Expm.Package.read("mypackage.exs")</code>      
    }, [:content, :assigns]


  
end