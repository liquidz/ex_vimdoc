defmodule Vimdoc.Template do
  @help_template ["..", "templates", "help.eex"]
  @textwidth     78

  def template_file do
    @help_template
    |> Path.join
    |> Path.expand(__DIR__)
  end

  def utilities do
    %{
      header: &header/2,
      link:   &link/2,
      join:   &join/2,
      spaces: &spaces/2,
    }
  end

  defp header(s, name) do
    spaces(s, "*#{name}-#{label(s)}*")
  end

  defp link(s, name) do
    spaces(s, "|#{name}-#{label(s)}|")
  end

  defp join(ls, prefix) do
    ls
    |> Enum.map(&("#{prefix}#{&1}"))
    |> Enum.join("\n")
  end

  defp label(s) do
    s |> String.strip |> String.replace(" ", "-") |> String.downcase
  end

  defp spaces(prefix, postfix) do
    len = [prefix, postfix]
    |> Enum.map(&String.length/1)
    |> Enum.reduce(&+/2)
    s = 1..(@textwidth - len) |> Enum.map(fn _ -> " " end) |> Enum.join("")
    "#{prefix}#{s}#{postfix}"
  end
end
