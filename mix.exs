defmodule Vimdoc.Mixfile do
  use Mix.Project

  @url "https://github.com/liquidz/ex_vimdoc"
  @description """
  Yet another vim helpfile generation tool.
  """

  def project do
    [
      app:          :vimdoc,
      version:      "0.0.1",
      elixir:       "~> 1.0",
      name:         "vimdoc",
      source_url:   @url,
      description:  @description,
      package:      package,
      escript:      [main_module: Vimdoc],
      deps:         deps
    ]
  end

  def application do
    [applications: [:logger, :yaml_elixir]]
  end

  defp deps do
    [
      {:pipette,     "~> 0.0.1"},
      {:yaml_elixir, "~> 1.0.0" },
      {:yamerl,      github: "yakaz/yamerl" }
    ]
  end

  defp package do
    [
      contributors: ["Masashi Iizuka"],
      licenses:     ["MIT"],
      links:        %{"Github" => @url}
    ]
  end
end
