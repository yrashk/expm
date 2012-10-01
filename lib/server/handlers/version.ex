defmodule Expm.Server.Http.Version do

  alias :cowboy_req, as: Req

  def init({:tcp, :http}, _req, _opts) do
    {:upgrade, :protocol, :cowboy_rest}
  end

  def rest_init(req, opts) do
    {:ok, req, opts}
  end

  def content_types_provided(req, state) do
    {[
       {{<<"text">>, <<"html">>, []}, :to_html},      
    ], req, state}
  end
  
  def to_html(req, state) do
    out = Expm.version
    {out, req, state}
  end

end
