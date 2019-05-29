defmodule Re.BuyerLeads.Budget do
  @moduledoc """
  Schema for facebook buyer leads
  """
  use Ecto.Schema

  import Ecto.Changeset

  require Logger

  alias Re.BuyerLead

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "budget_buyer_leads" do
    field :state, :string
    field :city, :string
    field :neighborhood, :string
    field :budget, :string

    field :state_slug, :string
    field :city_slug, :string

    belongs_to :user, Re.User,
      references: :uuid,
      foreign_key: :user_uuid,
      type: Ecto.UUID

    timestamps(type: :utc_datetime)
  end

  @params ~w(state city neighborhood budget user_uuid)a

  @sluggified_attr ~w(state city)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @params)
    |> validate_required(@params)
    |> generate_uuid()
    |> generate_slugs()
  end

  def generate_slugs(%{valid?: false} = changeset), do: changeset

  def generate_slugs(changeset) do
    Enum.reduce(@sluggified_attr, changeset, &Re.Slugs.generate_slug(&1, &2))
  end

  defp generate_uuid(changeset), do: Re.ChangesetHelper.generate_uuid(changeset)

  def buyer_lead_changeset(nil), do: raise("BuyerLeads.Budget not found")

  def buyer_lead_changeset(lead) do
    BuyerLead.changeset(%BuyerLead{}, %{
      name: lead.user.name,
      email: lead.user.email,
      phone_number: lead.user.phone,
      origin: "site",
      location: "#{lead.city_slug}|#{lead.state_slug}",
      budget: lead.budget,
      user_uuid: lead.user_uuid,
      neighborhood: lead.neighborhood
    })
  end
end
