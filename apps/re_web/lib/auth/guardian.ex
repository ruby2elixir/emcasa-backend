defmodule ReWeb.Guardian do
  @moduledoc """
  Module to implement guardian behavior
  """
  use Guardian, otp_app: :re_web

  alias Re.{
    Repo,
    User
  }

  def subject_for_token(resource, _claims) do
    {:ok, to_string(resource.id)}
  end

  def resource_from_claims(claims) do
    user = Repo.get(User, claims["sub"])

    if user do
      Timber.add_context(%Timber.Contexts.UserContext{
        id: user.id,
        email: user.email,
        name: user.name
      })
    end

    {:ok, user}
  end
end
