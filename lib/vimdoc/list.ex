defmodule Vimdoc.List do
  def strip(ls) do
    ls
    |> Enum.drop_while(&blank?/1)
    |> Enum.reverse
    |> Enum.drop_while(&blank?/1)
    |> Enum.reverse
  end

  defp blank?(s), do: s == ""
end
