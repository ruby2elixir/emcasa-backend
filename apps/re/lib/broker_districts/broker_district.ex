defmodule Re.BrokerDistrict do
  @moduledoc """
  Model for broker districts.
  """
  use Ecto.Schema

  import Ecto.Changeset

  schema "broker_districts" do
    belongs_to :user, Re.User,
               primary_key: true,
               foreign_key: :user_uuid,
               references: :uuid,
               type: Ecto.UUID

    belongs_to :district, Re.Addresses.District,
               primary_key: true,
               foreign_key: :district_uuid,
               references: :uuid,
               type: Ecto.UUID
    timestamps()
  end

  @required ~w(user_uuid district_uuid)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required)
    |> validate_required(@required)
  end
end
