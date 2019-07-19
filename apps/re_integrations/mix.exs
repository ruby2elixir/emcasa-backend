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
      compilers: Mix.compilers(),
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
      extra_applications: [:logger, :runtime_tools, :sentry]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ecto, "~> 3.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, "~> 0.13.0 or ~> 0.14.0"},
      {:re, in_umbrella: true},
      {:plug_cowboy, "~> 2.0"},
      {:cors_plug, "~> 1.2"},
      {:comeonin, "~> 3.2"},
      {:swoosh, "~> 0.23"},
      {:elasticsearch, "~> 1.0.0"},
      {:pigeon, "~> 1.3.1"},
      {:kadabra, "~> 0.4.2"},
      {:retry, "~> 0.10"},
      {:httpoison, "~> 1.3", override: true},
      {:jason, "~> 1.0"},
      {:sentry, "~> 7.0"},
      {:ex_machina, "~> 2.2", only: :test},
      {:ecto_job, "~> 2.0"},
      {:cloudex, git: "https://github.com/emcasa/cloudex.git"},
      {:google_api_calendar, "~> 0.6.1"},
      {:goth, "~> 1.1.0"}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
