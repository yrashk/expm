defmodule Expm.Server.Templates.Package do
  require EEx

  EEx.function_from_string :def, :description,
    %s{
      <%= description %>
    }, [:description, :_assigns]

  EEx.function_from_string :def, :directories,
    %s{
      <%= lc dir inlist directories do %>
        <span class="label"><%= dir %></span>
      <% end %>
    }, [:directories, :_assigns]

  EEx.function_from_string :def, :homepage,
    %s{
      <%= if nil?(homepage) do %>
      <% else %>
        <a href="<%= homepage %>"><%= homepage %></a>
      <% end %>
    }, [:homepage, :_assigns]

  EEx.function_from_string :def, :keywords,
    %s{
      <%= lc keyword inlist keywords do %>
        <span class="label label-info"><%= keyword %></span>
      <% end %>
    }, [:keywords, :_assigns]

  EEx.function_from_string :def, :metadata,
    %s{
      <%= lc \{tag, value \} inlist metadata do %>
        <span class="label label-info"><%= tag %>:</span> <%= inspect value %>
      <% end %>
    }, [:metadata, :_assigns]

  EEx.function_from_string :def, :name,
    %s{
      <strong><%= name %></strong>
    }, [:name, :_assigns]

  EEx.function_from_string :def, :repositories,
    %s{
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
    }, [:repositories, :_assigns]


  EEx.function_from_string :def, :version,
    %s{
      <%= version %>
    }, [:version, :_assigns]

  EEx.function_from_string :def, :dependencies,
    %s|
      <%= lc dependency inlist dependencies do %>
        <% [{name, actual_version}] = Expm.Package.deps(@repo, Expm.Package.new(dependencies: [dependency])) %>
        <% if is_binary(dependency), do: version = "topmost", else: {_, version} = dependency %>
        <a href="/<%= name %>/<%= actual_version %>" class="btn btn-mini btn-info"><%= name %> (<em><%= Expm.Package.inspect_version(version) %></em>)</a>
      <% end %>
    |, [:dependencies, :assigns]

  EEx.function_from_string :def, :licenses,
    %s{
      <%= lc license inlist licenses do %>
        <span class="label label-success"><%= license[:name] %></span>
      <% end %>
    }, [:licenses, :_assigns]

  def maintainers(maintainers, assigns), do: people(maintainers, assigns)
  def contributors(contributors, assigns), do: people_without_email(contributors, assigns)

  EEx.function_from_string :defp, :people,
    %s{
      <%= lc person inlist people do %>
        <span class="label label-success"><%= person[:name] %> &lt;<span class="b64"><%= :base64.encode(person[:email]) %></span>&gt;</span>
      <% end %>
    }, [:people, :_assigns]

  EEx.function_from_string :defp, :people_without_email,
    %s{
      <%= lc person inlist people do %>
        <span class="label label-success"><%= person[:name] %></span>
      <% end %>
    }, [:people, :_assigns]

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

  def render(repo, field, value) do
    if function_exported?(__MODULE__, field, 2) do
      apply(__MODULE__, field, [value, repo: repo])
    else
      inspect value
    end
  end

end

defmodule Expm.Server.Templates do
  require EEx

  templates_dir = Path.join([Path.dirname(__FILE__),"templates"])

  EEx.function_from_file :def, :list,
                         Path.join(templates_dir,"list.html.eex"),
                         [:pkgs, :title]

  EEx.function_from_file :def, :package,
                         Path.join(templates_dir,"package.html.eex"),
                         [:package, :repo]

  EEx.function_from_file :def, :page, 
                         Path.join(templates_dir,"page.html.eex"),
                         [:content, :assigns]
  
end
