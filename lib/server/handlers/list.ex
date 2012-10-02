defmodule Expm.Server.Http.List do
  use Expm.Server.Http

  def allowed_methods(req, state) do
    {["GET", "PUT", "POST"], req, state}
  end

  def process_elixir(req, State[repository: repository] = state) do
    {:ok, body, req} = Req.body(req)
    filter = Expm.Package.decode body  
    pkgs = Expm.Package.filter repository, filter
    req = Req.set_resp_body(inspect(pkgs), req)
    {true, req, state}
  end

  def to_html(req, State[repository: repository] = state) do
    {kwd, req} = Req.qs_val("q", req, "")
    pkgs = Expm.Package.search repository, kwd    
    out = Expm.Server.Http.render_page(Expm.Server.Templates.list(pkgs, (if kwd == "", do: "Index", else: "Search: #{kwd}")), req, state)
    {out, req, state}
  end

end