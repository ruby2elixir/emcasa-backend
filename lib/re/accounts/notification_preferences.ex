defmodule Re.Accounts.NotificationPreferences do
  @moduledoc """
  Embedded schema for notification prefenreces
  """
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :email, :boolean, default: true
    field :app, :boolean, default: true
  end

  @attributes ~w(email app)a

  def changeset(struct, params \\ %{}), do: cast(struct, params, @attributes)
end
