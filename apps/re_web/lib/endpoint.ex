defmodule ReWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :re
  use Absinthe.Phoenix.Endpoint

  socket("/socket", ReWeb.UserSocket)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug(Phoenix.CodeReloader)
  end

  plug(Plug.RequestId)

  plug(
    Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug(
    Plug.Session,
    store: :cookie,
    key: "_re_key",
    signing_salt: "BJUIPFWh"
  )

  plug(CORSPlug)

  # Add Timber plugs for capturing HTTP context and events
  plug(Timber.Plug.SessionContext)
  plug(Timber.Plug.HTTPContext)
  plug(Timber.Plug.Event)

  plug(ReWeb.Router)

  def node_name, do: node()
end
