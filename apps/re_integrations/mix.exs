defmodule ReIntegrations.Mixfile do
  use Mix.Project

  def project do
    [
      app: :re_integrations,
      version: "0.0.1",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test]
    ]
  end

  def application do
    [
      mod: {ReIntegrations.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:re, in_umbrella: true},
      {:re_web, in_umbrella: true},
      {:phoenix, "~> 1.3.0"},
      {:cowboy, "~> 1.0"},
      {:cors_plug, "~> 1.2"},
      {:comeonin, "~> 3.2"},
      {:swoosh, "~> 0.13"},
      {:elasticsearch, "~> 0.4"},
      {:absinthe, "~> 1.4"},
      {:phoenix_swoosh, "~> 0.2"},
      {:pigeon, "~> 1.2.2"},
      {:kadabra, "~> 0.4.2"},
      {:retry, "~> 0.10"},
      {:httpoison, "~> 1.3", override: true},
      {:honeybadger, "~> 0.10"}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
