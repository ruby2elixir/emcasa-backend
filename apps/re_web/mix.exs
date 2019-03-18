defmodule ReWeb.Mixfile do
  use Mix.Project

  def project do
    [
      app: :re_web,
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
      mod: {ReWeb.Application, []},
      extra_applications: [:logger, :runtime_tools, :sentry]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:re, in_umbrella: true},
      {:re_integrations, in_umbrella: true},
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 3.0"},
      {:gettext, "~> 0.11"},
      {:plug_cowboy, "~> 1.0"},
      {:cors_plug, "~> 1.2"},
      {:guardian, "~> 1.0"},
      {:bodyguard, "~> 2.1"},
      {:absinthe, "~> 1.5.0-alpha.1", override: true},
      {:absinthe_plug, "~> 1.4.6"},
      {:absinthe_phoenix, "~> 1.4"},
      {:dataloader, "~> 1.0.4"},
      {:currency_formatter, "~> 0.4"},
      {:apollo_tracing, "~> 0.4.0"},
      {:timex, "~> 3.3"},
      {:tzdata, "~> 0.5"},
      {:account_kit, github: "rhnonose/account_kit"},
      {:timber_plug, "~> 1.0"},
      {:timber_phoenix, "~> 1.0"},
      {:jason, "~> 1.0"}
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
