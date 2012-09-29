defmodule Expm.Client do
  use Application.Behaviour
  alias GenX.Supervisor, as: Sup

  def start(_, _) do
   Sup.start_link sup_tree
  end

  defp sup_tree do
    Sup.OneForOne.new(id: Expm.Client.Sup)
  end
end
