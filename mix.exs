defmodule Re.Umbrella.Mixfile do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test]
    ]
  end

  defp deps do
    [
      {:credo, "~> 0.9", only: [:dev, :test], runtime: false},
      {:timber, "~> 3.0.0"},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

  defp aliases do
    [
      "git.hook": &git_hook/1
    ]
  end

  defp git_hook(_) do
    Mix.shell().cmd("cp priv/git/pre-commit .git/hooks/pre-commit")
    Mix.shell().cmd("chmod +x .git/hooks/pre-commit")
  end
end
