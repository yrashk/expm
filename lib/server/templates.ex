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
          <a href="<%= github_url(repository) %>"><%= repository[:github] %></a>
        <% end %>
        <%= if repository[:git] do %>
          <span class="label label-important">Git</span>
          <a href="<%= repository[:git] %>"><%= repository[:git] %></a>
        <% end %>        
        <%= if repository[:git] do %>
          <span class="label label-important">Git</span>
          <a href="<%= repository[:git] %>"><%= repository[:git] %></a>
        <% end %>
        <%= if repository[:url] do %>
          <span class="label label-important">URL</span>
          <a href="<%= repository[:url] %>"><%= repository[:url] %></a>
        <% end %>
      <% end %>
    }, [:repositories]


  EEx.function_from_string :def, :version,
    %b{
      <%= version %>
    }, [:version]

  EEx.function_from_string :def, :dependencies,
    %b|
      <%= lc dependency inlist dependencies do %>
        <%= if is_binary(dependency) do %>
          <a href="/<%= dependency %>" class="btn btn-mini btn-info"><%= dependency %></a>
        <% end %>
        <%= if match?({name, version}, dependency) do %>
          <a href="/<%= name %>/<%= version %>" class="btn btn-mini btn-info"><%= name %> (<em><%= version %></em>)</a>
        <% end %>        
      <% end %>
    |, [:dependencies]

  def maintainers(maintainers), do: people(maintainers)
  def contributors(contributors), do: people(contributors)

  EEx.function_from_string :defp, :people,
    %b{
      <%= lc person inlist people do %>
        <span class="label label-success"><%= person[:name] %> &lt;<span class="b64"><%= :base64.encode(person[:email]) %></span>&gt;</span>
      <% end %>
    }, [:people]

  defp github_url(repository) do
    "https://github.com/#{repository[:github]}" <>
    cond do
      repository[:branch] ->
        "/tree/#{repository[:branch]}"
      repository[:tag] ->
        "/tree/#{repository[:tag]}"
      true -> ""
     end
  end

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

  templates_dir = File.join([File.dirname(__FILE__),"templates"])

  EEx.function_from_file :def, :list,
                         File.join(templates_dir,"list.html.eex"),
                         [:pkgs, :title]

  EEx.function_from_file :def, :package,
                         File.join(templates_dir,"package.html.eex"),
                         [:package, :repo]

  EEx.function_from_file :def, :page, 
                         File.join(templates_dir,"page.html.eex"),
                         [:content, :assigns]
  
end