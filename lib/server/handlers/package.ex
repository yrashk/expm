defmodule Expm.Server.Http.Package do
  use Expm.Server.Http

  def is_authorized(req, state) do
    case Req.method(req) do
      {"GET",req} -> {true, req, state}
      {_, req} ->
        {auth, req} = Req.header("authorization", req)
        case auth do 
          :undefined -> {{false, %b{Basic realm="expm"}}, req, state}
          _ ->
              ["Basic", auth] = String.split(auth, " ")
              [username, auth] = String.split(:base64.decode(auth), ":")
              # I know this isn't strong enough, but it generates predictable auth tokens
              # (which is what Auth currently needs)
              auth = :crypto.hash(:sha256, auth) 
              repository = Expm.Repository.Auth.new username: username, 
                                                    auth_token: auth, 
                                                    repository: state.opts[:repository]
              {true, req, state.repository(repository)}
        end
      end
  end

  def resource_exists(req, State[repository: repository] = state) do
    {package, req} = Req.binding(:package, req)  
    pkg = Expm.Package.fetch repository, package
    {pkg != :not_found, req, state.package(pkg)}
  end

  def process_elixir(req, State[repository: repository] = state) do
    {:ok, body, req} = Req.body(req)
    pkg = Expm.Package.decode body
    case Expm.Repository.put(repository, pkg) do
      Expm.Package[] = pkg ->
        Lager.info "Published #{pkg.name}:#{pkg.version}"    
        req = Req.set_resp_body(pkg.encode, req)
        {true, req, state}
      other ->
        Lager.error "Failed publishing #{pkg.name} :: #{pkg.version}: #{inspect other}"
        req = Req.set_resp_body(inspect(other), req)                
        {true, req, state}
    end
  end

  def to_html(req, State[repository: repository, package: pkg] = state) do
    tpl = Expm.Server.Templates.package(pkg, repository)
    out = Expm.Server.Http.render_page(tpl, req, state,
                                       title: "#{pkg.name} (#{pkg.version})", 
                                       subtitle: pkg.description)
    {out, req, state}
  end

  def to_elixir(req, State[repository: repository, package: pkg] = state) do
    versions = Expm.Package.versions repository, pkg.name
    {inspect(versions), req, state}
  end

  def delete_resource(req, State[repository: repository, package: pkg] = state) do
    {Expm.Package.delete(repository, pkg.name) == :ok, req, state}
  end


end
