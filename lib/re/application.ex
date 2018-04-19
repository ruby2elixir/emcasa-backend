defmodule Re.Application do
  @moduledoc """
  Main module for Re, starts supervision tree.
  """

  use Application

  alias ReWeb.{
    Endpoint,
    Notifications.Emails
  }

  alias Re.Stats.Visualizations

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Re.Repo, []),
      supervisor(ReWeb.Endpoint, []),
      supervisor(Absinthe.Subscription, [ReWeb.Endpoint]),
      worker(Visualizations, []),
      worker(Emails.Server, [])
    ]

    opts = [strategy: :one_for_one, name: Re.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
