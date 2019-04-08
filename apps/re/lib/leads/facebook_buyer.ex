defmodule Re.Leads.FacebookBuyer do
  @moduledoc """
  Schema for facebook buyer leads
  """
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "facebook_buyer_leads" do
    field :full_name, :string
    field :email, :string
    field :phone_number, :string
    field :neighborhoods, :string
    field :timestamp, :utc_datetime
    field :lead_id, :string

    timestamps()
  end

  @params ~w(full_name email phone_number neighborhoods timestamp lead_id)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @params)
    |> generate_uuid()
  end

  defp generate_uuid(changeset), do: Re.ChangesetHelper.generate_uuid(changeset)
end
