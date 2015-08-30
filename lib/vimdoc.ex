defmodule Vimdoc do
  @config_yaml "vimdoc.yml"
  @plugin_dirs ["plugin", "ftplugin", "autoload"]

  def read_config, do: read_config(".")
  def read_config(path) do
    Path.join(path, @config_yaml)
    |> YamlElixir.read_from_file
    |> Vimdoc.Dict.keyDict
  end

  def plugin_files(path \\ ".") do
    @plugin_dirs
    |> Enum.map(&Path.join(path, &1))
    |> Enum.flat_map(&Vimdoc.File.find/1)
  end

  def exclude_files(files, excludes) do
    regexs = excludes |> Enum.map(&Regex.compile!/1)
    files |> Enum.reject(fn x ->
      Enum.any?(regexs, &Regex.match?(&1, x))
    end)
  end

  def main(path) do
    conf = read_config(path)
    tmpl = Vimdoc.Template.template_file
    dest = Path.join [path, "doc", "#{conf.name}.txt"]

    plugin_files(path)
    |> exclude_files(conf.exclude)
    |> Enum.map(&File.read!/1)
    |> Enum.flat_map(&Vimdoc.Parser.parse/1)
    |> Enum.reverse # to preserve ordering after group_by
    |> Enum.group_by(&(:"#{&1.type}"))
    |> Dict.merge(%{template: tmpl, destination: dest})
    |> Dict.merge(Vimdoc.Template.utilities)
    |> Dict.merge(conf)
    |> Pipette.build()
  end
end
