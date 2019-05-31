defmodule ReWeb.Monitoring do
  @moduledoc """
  Configuration for Prometheus monitoring
  """

  def setup() do
    ReWeb.Endpoint.PhoenixInstrumenter.setup()
    ReWeb.PlugPipelineInstrumenter.setup()
    ReWeb.PlugExporter.setup()
    require Prometheus.Registry

    Prometheus.Registry.register_collector(:prometheus_process_collector)
  end
end

defmodule ReWeb.PlugPipelineInstrumenter do
  use Prometheus.PlugPipelineInstrumenter
end

defmodule ReWeb.Endpoint.PhoenixInstrumenter do
  use Prometheus.PhoenixInstrumenter
end

defmodule ReWeb.PlugExporter do
  use Prometheus.PlugExporter
end
