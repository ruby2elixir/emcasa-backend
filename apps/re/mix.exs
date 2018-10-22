defmodule Re.Mixfile do
  use Mix.Project

  def project do
    [
      app: :re,
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
      mod: {Re.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ecto, "~> 1.0 or ~> 2.0 or ~> 2.1"},
      {:postgrex, ">= 0.0.0"},
      {:comeonin, "~> 3.2"},
      {:ex_machina, "~> 2.1", only: :test},
      {:bodyguard, "~> 2.1"},
      {:faker, "~> 0.9.0", only: :test},
      {:email_checker, "~> 0.1"},
      {:dataloader, "~> 1.0"},
      {:currency_formatter, "~> 0.4"},
      {:excoveralls, "~> 0.8", only: :test},
      {:timber, "~> 2.6"},
      {:nimble_csv, "~> 0.3"},
      {:timex, "~> 3.3"},
      {:tzdata, "~> 0.5"},
      {:quantum, "~> 2.2"},
      {:account_kit, github: "rhnonose/account_kit"},
      {:xml_builder, "~> 2.1"},
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
