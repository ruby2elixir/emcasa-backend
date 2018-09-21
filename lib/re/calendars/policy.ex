defmodule Re.Calendars.Policy do
  @moduledoc """
  Authorization policies for calendars
  """

  alias Re.User

  def authorize(_, %User{role: "admin"}, _), do: :ok
  def authorize(:schedule_tour, %User{role: "user"}, _), do: :ok

  def authorize(_, nil, _), do: {:error, :unauthorized}

  def authorize(_, _, _), do: {:error, :forbidden}
end
