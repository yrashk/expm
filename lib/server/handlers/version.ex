defmodule Expm.Server.Http.Version do
  use Expm.Server.Http

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
