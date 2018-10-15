defmodule ReWeb.GuardianPipeline do
  @moduledoc """
  Module to define guardian related plugs into a pipeline
  """
  @claims %{typ: "access"}

  use Guardian.Plug.Pipeline,
    otp_app: :re,
    module: ReWeb.Guardian,
    error_handler: ReWeb.Guardian.AuthErrorHandler

  plug(Guardian.Plug.VerifySession, claims: @claims)
  plug(Guardian.Plug.VerifyHeader, claims: @claims, realm: "Token")
  plug(Guardian.Plug.LoadResource, allow_blank: true)
end
