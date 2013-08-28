defmodule Expm.Package.Decoder do
  defexception SecurityException, message: nil
  def decode({ :__block__, _, [b] }) when is_list(b) do
    decode(b)
  end
  def decode(list) when is_list(list) do
    lc i inlist list, do: decode(i)
  end
  def decode({{:.,_,[Kernel,:access]},l1,[{:__aliases__,l2,[:Expm,:Package]}|rest]}) do
    {:access,l1,[{:__aliases__,l2,[:Expm,:Package]}|decode_1(rest)]}
  end
  def decode(v) do
    raise SecurityException.new(message: "#{Macro.to_string(v)} is not allowed")
  end

  defp decode_1({ :{}, b, c }) do
    {:{}, b, decode_1(c) }
  end

  defp decode_1({ _a, _b, _c }=v) do
    raise SecurityException.new(message: "#{Macro.to_string(v)} is not allowed")
  end

  defp decode_1({ a, b }) do
    { decode_1(a), decode_1(b) }
  end

  defp decode_1(list) when is_list(list) do
    lc i inlist list, do: decode_1(i)
  end

  defp decode_1(other) do
    other
  end
end
