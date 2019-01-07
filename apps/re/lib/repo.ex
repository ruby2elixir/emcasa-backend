defmodule Re.Repo do
  use Ecto.Repo, otp_app: :re
  use Scrivener, page_size: 20

  def init(_, opts) do
    :ok =
      Telemetry.attach(
        "timber-ecto-query-handler",
        [:re, :repo, :query],
        Timber.Ecto,
        :handle_event,
        []
      )

    {:ok, opts}
  end
end
