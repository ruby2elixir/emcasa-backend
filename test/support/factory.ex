defmodule Re.Factory do
  @moduledoc """
  Use the factories here in tests.
  """

  use ExMachina.Ecto, repo: Re.Repo

  def user_factory do
    %ReWeb.User {
      email: "user@example.com",
      password: "password"
    }
  end
end
