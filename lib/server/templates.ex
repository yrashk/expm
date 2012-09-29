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
end