defmodule Expm.Utils do
  defmacro deflist({list, _, _}, {item, _, _}) do
    quote do
      def unquote(item)(v, rec), do: rec.unquote(list)([v|rec.unquote(list)])
    end
  end
end
