defmodule ReWeb.AbsintheInstrumenter do
  use Prometheus.Metric
  require Prometheus.Contrib.HTTP

  @events [
    [:absinthe, :resolve, :field, :start],
    [:absinthe, :resolve, :field],
    [:absinthe, :execute, :operation, :start],
    [:absinthe, :execute, :operation],
    [:absinthe, :subscription, :publish, :start],
    [:absinthe, :subscription, :publish]
  ]

  @duration_names [
    {:absinthe_execution_duration_milliseconds, "execution"},
    {:absinthe_subscription_publish_duration_milliseconds, "subscription publish"},
    {:absinthe_resolution_duration_milliseconds, "resolution"}
  ]

  @counter_names [
    {:absinthe_execution_counter, "execution"},
    {:absinthe_subscription_publish_counter, "subscription publish"},
    {:absinthe_resolution_duration_counter, "resolution"}
  ]

  def setup do
    declare_sumaries(@duration_names)
    declare_histograms(@duration_names)
    declare_counters(@counter_names)

    :telemetry.attach_many("absinthe-instrumenter", @events, &handle_event/4, nil)
  end

  defp declare_sumaries(names) do
    Enum.each(names, fn {name, help} ->
      Summary.declare(name: name, help: "Graphql #{help} duration")
    end)
  end

  defp declare_histograms(names) do
    Enum.each(names, fn {name, help} ->
      Histogram.declare(
        name: name,
        buckets: [
          10,
          100,
          1_000,
          10_000,
          100_000,
          300_000,
          500_000,
          750_000,
          1_000_000,
          1_500_000,
          2_000_000,
          3_000_000
        ],
        help: "Absinthe #{help} duration"
      )
    end)
  end

  defp declare_counters(names) do
    Enum.each(names, fn {name, help} ->
      Counter.declare(
        name: name,
        help: "Absinthe #{help} count"
      )
    end)
  end

  def handle_event(
        [:absinthe, :execute, :operation],
        %{duration: duration},
        %{options: options},
        _config
      ) do
    Summary.observe([name: :absinthe_execution_duration_milliseconds], duration)
    Histogram.observe([name: :absinthe_execution_duration_milliseconds], duration)
  end

  def handle_event(
        [:absinthe, :subscription, :publish],
        %{duration: duration},
        _metadata,
        _config
      ) do
    Summary.observe([name: :absinthe_subscription_publish_duration_milliseconds], duration)
    Histogram.observe([name: :absinthe_subscription_publish_duration_milliseconds], duration)
  end

  def handle_event([:absinthe, :resolve, :field], %{duration: duration}, _metadata, _config) do
    Summary.observe([name: :absinthe_resolution_duration_milliseconds], duration)
    Histogram.observe([name: :absinthe_resolution_duration_milliseconds], duration)
  end

  def handle_event([:absinthe, :execute, :operation, :start], _measurements, _metadata, _config) do
    Counter.inc(name: :absinthe_execution_counter)
  end

  def handle_event(
        [:absinthe, :subscription, :publish, :start],
        _measurements,
        _metadata,
        _config
      ) do
    Counter.inc(name: :absinthe_subscription_publish_counter)
  end

  def handle_event([:absinthe, :resolve, :field, :start], _measurements, _metadata, _config) do
    Counter.inc(name: :absinthe_resolution_duration_counter)
  end
end
