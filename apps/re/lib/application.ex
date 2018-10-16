defmodule Re.Application do
  @moduledoc """
  Application module for Re, starts supervision tree.
  """

  use Application

  alias Re.Statistics.{
    Scheduler,
    Visualizations
  }

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Re.Repo, []),
      worker(Visualizations, []),
      worker(Scheduler, [])
    ]

    opts = [strategy: :one_for_one, name: Re.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
