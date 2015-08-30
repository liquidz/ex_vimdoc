defmodule Vimdoc.Parser do
  def parse(file_body) do
    file_body
    |> String.split(~r{\r?\n})
    |> Enum.map(&String.strip/1)
    |> tokenize([], [], false)
    |> analyze
  end

  def tokenize([], result, _, _), do: result
  def tokenize([line | tail], result, tmp, started?) do
    case line do
      "\"\"" ->
        tokenize(tail, result, tmp, true)
      "\" " <> s when started? ->
        tokenize(tail, result, tmp ++ [s], true)
      "\"" when started? ->
        tokenize(tail, result, tmp ++ [""], true)
      s when started? ->
        ls = Vimdoc.List.strip(tmp)
        tokenize(tail, result ++ [{ls, s}], [], false)
      _ ->
        tokenize(tail, result, [], false)
    end
  end

  defp annotation?(s), do: String.starts_with?(s, "@")

  def analyze(ls) do
    ls
    |> Enum.map(fn {lines, code} ->
      {ann, lines} = Enum.split_while(lines, &annotation?/1)

      data = %{type: code_to_type(code), lines: lines}
      |> Dict.merge(analyze_annotation(ann))

      case data.type do
        "variable" -> analyze_variable_code(code)
        "function" -> analyze_function_code(code)
        "command"  -> analyze_command_code(code)
        "mapping"  -> analyze_mapping_code(code)
        _          -> %{}
      end
      |> Dict.merge(data)
    end)
  end

  def analyze_annotation(lines) do
    lines
    |> Enum.map(&String.strip/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(fn ("@" <> s) ->
      case s |> String.strip |> String.split(~r/ +/) do
        [k, v] -> {:"#{k}", v}
        _      -> nil
      end
    end)
    |> Enum.reject(&(&1 == nil))
    |> Enum.into(%{})
  end

  defp code_to_type(code) do
    cond do
      code =~ ~r/g:[^ '"]/           -> "variable"
      code =~ ~r/function/           -> "function"
      code =~ ~r/command/            -> "command"
      code =~ ~r/([invx](nor)?)?map/ -> "mapping"
      true                           -> "introduction"
    end
  end

  defp analyze_variable_code(code) do
    [name] = Regex.run(~r/g:[^ '"=]+/, code)
    %{name: name}
  end

  defp analyze_function_code(code) do
    [_, name, param] = Regex.run(~r/function!? +(.+)(\(.*\))/, code)
    %{name: name, param: param}
  end

  defp analyze_command_code(code) do
    name = code
    |> String.split(~r/ +/)
    |> Enum.drop(1)
    |> Enum.reject(&Regex.match?(~r/^-/, &1))
    |> List.first
    %{name: ":" <> name}
  end

  defp analyze_mapping_code(code) do
    [name] = Regex.run(~r/<Plug>[^ ]+/, code)
    %{name: name}
  end
end
