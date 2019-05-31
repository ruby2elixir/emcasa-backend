defmodule Re.Monitoring do
  @moduledoc """
  Configuration for Prometheus monitoring
  """

  def setup() do
    Re.Repo.Instrumenter.setup()
    require Prometheus.Registry

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
        &Re.Repo.Instrumenter.handle_event/4,
        %{}
      )
  end
end

defmodule Re.Repo.Instrumenter do
  use Prometheus.EctoInstrumenter
end
