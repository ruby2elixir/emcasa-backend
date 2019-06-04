defmodule Re.Monitoring do
  @moduledoc """
  Configuration for Prometheus monitoring for Re app
  """
  require Prometheus.Registry

  alias Re.Repo.Instrumenter

  def setup do
    Instrumenter.setup()

    Prometheus.Registry.register_collector(:prometheus_process_collector)

    attach_telemetry()
  end

  defp attach_telemetry do
    :ok =
      :telemetry.attach(
        "timber-ecto-query-handler",
        [:re, :repo, :query],
        &Timber.Ecto.handle_event/4,
        []
      )

    :ok =
      :telemetry.attach(
        "prometheus-ecto",
        [:re, :repo, :query],
        &Instrumenter.handle_event/4,
        %{}
      )
  end
end

defmodule Re.Repo.Instrumenter do
  @moduledoc false
  use Prometheus.EctoInstrumenter
end
