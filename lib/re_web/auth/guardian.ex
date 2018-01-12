defmodule ReWeb.Guardian do
  @moduledoc """
  Module to implement guardian behavior
  """
  use Guardian, otp_app: :re

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
      %Timber.Contexts.UserContext{id: user.id, email: user.email, name: user.name}
      |> Timber.add_context()
    end

    {:ok, user}
  end
end
