defmodule Vimdoc.Dict do
  def keyDict(x) when is_map(x) do
    Enum.map(x, fn {k, v} ->
      {:"#{k}", keyDict(v)}
    end)
    |> Enum.into(%{})
  end

  def keyDict(x) when is_list(x) do
    Enum.map(x, &keyDict/1)
  end

  def keyDict(x), do: x
end
