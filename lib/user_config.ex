defmodule Expm.UserConfig do

    def read do
      if File.exists?(filename) do
        {:ok, b} = File.read(filename)
        {v, _} = Code.eval_string(b, [], file: filename, line: 1)
        v
      else 
        []
      end
    end

    def set(option, value) do
      opts = read
      opts = Keyword.put opts, option, value
      vals = List.flatten(lc {k,v} inlist opts, do: ["#{k}: #{inspect v}",","])
      vals = Enum.reverse(tl(Enum.reverse(vals)))
      str = "[" <> list_to_binary(vals)  <> "]"
      File.write(filename, str)
    end

    def get(option, default // nil) do
      read[option] || default
    end

    def filename do
      Path.join(System.get_env("HOME"), ".expm.config")
    end
end