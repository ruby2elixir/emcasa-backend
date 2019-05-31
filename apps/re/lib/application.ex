defmodule Re.Application do
  @moduledoc """
  Application module for Re, starts supervision tree.
  """

  use Application

  import Supervisor.Spec

  alias Re.{
    BuyerLeads,
    Developments,
    Listings.History,
    PubSub,
    Repo,
    Statistics.Visualizations
  }

  def start(_type, _args) do
    Re.Monitoring.setup()

    children =
      [
        supervisor(Repo, []),
        supervisor(Phoenix.PubSub.PG2, [PubSub, []])
      ] ++ extra_processes(Mix.env())

    opts = [strategy: :one_for_one, name: Re.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp extra_processes(:test), do: []

  defp extra_processes(_),
    do: [
      worker(History.Server, []),
      worker(Visualizations, []),
      {BuyerLeads.JobQueue, repo: Repo},
      {Developments.JobQueue, repo: Repo}
    ]
end
