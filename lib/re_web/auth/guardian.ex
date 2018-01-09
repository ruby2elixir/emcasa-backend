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
    {:ok, Repo.get(User, claims["sub"])}
  end
end
