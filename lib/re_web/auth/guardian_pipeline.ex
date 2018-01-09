defmodule ReWeb.GuardianPipeline do
  @claims %{typ: "access"}

  use Guardian.Plug.Pipeline, otp_app: :re,
                              module: ReWeb.Guardian,
                              error_handler: ReWeb.Guardian.AuthErrorHandler

  plug Guardian.Plug.VerifySession, claims: @claims
  plug Guardian.Plug.VerifyHeader, claims: @claims, realm: "Token"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, ensure: true
end
