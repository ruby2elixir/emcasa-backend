defmodule Re.Application do
  @moduledoc """
  Application module for Re, starts supervision tree.
  """

  use Application

  import Supervisor.Spec

  alias Re.{
    History.Server,
    Statistics.Scheduler,
    Statistics.Visualizations
  }

  def start(_type, _args) do
    children =
      [
        supervisor(Re.Repo, []),
        supervisor(Phoenix.PubSub.PG2, [Re.PubSub, []])
      ] ++ extra_processes(Mix.env())

    opts = [strategy: :one_for_one, name: Re.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp extra_processes(:test), do: []

  defp extra_processes(_),
    do: [
      worker(Server, []),
      worker(Visualizations, []),
      worker(Scheduler, [])
    ]
end
