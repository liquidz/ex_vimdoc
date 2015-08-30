defmodule Vimdoc.File do
  def find(path) do
    case File.ls(path) do
      {:error, _} -> []
      {:ok, list} ->
        list
        |> Enum.flat_map(fn f ->
          path = Path.join(path, f)
          if File.dir?(path) do
            find path
          else
            [path]
          end
        end)
    end
  end
end
