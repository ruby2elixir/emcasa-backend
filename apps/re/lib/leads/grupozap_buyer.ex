defmodule Re.Leads.GrupozapBuyer do
  @moduledoc """
  Schema for buyer leads
  """
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "grupozap_buyer_leads" do
    field :lead_origin, :string
    field :timestamp, :utc_datetime
    field :origin_lead_id, :string
    field :origin_listing_id, :string
    field :client_listing_id, :string
    field :name, :string
    field :email, :string
    field :ddd, :string
    field :phone, :string
    field :message, :string

    timestamps()
  end

  @params ~w(lead_origin timestamp origin_lead_id origin_listing_id client_listing_id
    name email ddd phone message)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @params)
    |> generate_uuid()
  end

  defp generate_uuid(changeset), do: Re.ChangesetHelper.generate_uuid(changeset)
end
