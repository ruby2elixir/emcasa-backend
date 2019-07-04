defmodule ReWeb.Monitoring do
  @moduledoc """
  Configuration for Prometheus monitoring for ReWeb app
  """

  require Prometheus.Registry

  alias ReWeb.{
    Endpoint,
    PlugExporter,
    PlugPipelineInstrumenter,
    AbsintheInstrumenter
  }

  def setup do
    Endpoint.PhoenixInstrumenter.setup()
    PlugPipelineInstrumenter.setup()
    PlugExporter.setup()
    AbsintheInstrumenter.setup()

    Prometheus.Registry.register_collector(:prometheus_process_collector)
  end
end

defmodule ReWeb.PlugPipelineInstrumenter do
  @moduledoc false
  use Prometheus.PlugPipelineInstrumenter
end

defmodule ReWeb.Endpoint.PhoenixInstrumenter do
  @moduledoc false
  use Prometheus.PhoenixInstrumenter
end

defmodule ReWeb.PlugExporter do
  @moduledoc false
  use Prometheus.PlugExporter
end
