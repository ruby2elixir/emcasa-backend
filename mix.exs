defmodule Re.Mixfile do
  use Mix.Project

  def project do
    [
      app: :re,
      version: "0.0.1",
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
      mod: {Re.Application, []},
      applications: [
        :phoenix,
        :phoenix_pubsub,
        :cowboy,
        :logger,
        :gettext,
        :phoenix_ecto,
        :postgrex,
        :comeonin,
        :swoosh,
        :phoenix_swoosh,
        :timber,
        :timex,
        :nimble_csv
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:cors_plug, "~> 1.2"},
      {:credo, "~> 0.9", only: [:dev, :test], runtime: false},
      {:comeonin, "~> 3.2"},
      {:guardian, "~> 1.0"},
      {:ex_machina, "~> 2.1", only: :test},
      {:swoosh, "~> 0.13"},
      {:bodyguard, "~> 2.1"},
      {:timber, "~> 2.6"},
      {:faker, "~> 0.9.0", only: :test},
      {:email_checker, "~> 0.1"},
      {:absinthe, "~> 1.4"},
      {:absinthe_plug, "~> 1.4"},
      {:absinthe_phoenix, "~> 1.4"},
      {:elasticsearch, "~> 0.4"},
      {:dataloader, "~> 1.0"},
      {:currency_formatter, "~> 0.4"},
      {:excoveralls, "~> 0.8", only: :test},
      {:nimble_csv, "~> 0.3"},
      {:apollo_tracing, "~> 0.4.0"},
      {:timex, "~> 3.3"},
      {:tzdata, "~> 0.5"},
      {:quantum, "~> 2.2"},
      {:phoenix_swoosh, "~> 0.2"}
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
