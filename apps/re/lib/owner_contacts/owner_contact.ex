defmodule Re.OwnerContact do
  @moduledoc """
  Model for listing owner contact.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Re.{
    ChangesetHelper,
    Slugs
  }

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "owner_contacts" do
    field :name, :string
    field :name_slug, :string
    field :phone, :string
    field :email, :string

    timestamps(type: :utc_datetime)
  end

  @required ~w(name phone)a

  @optional ~w(email)a

  @sluggified_attr ~w(name)a

  @all @required ++ @optional

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @all)
    |> validate_required(@required)
    |> validate_email()
    |> unique_constraint(:phone, name: :owners_contacts_name_phone)
    |> generate_uuid()
    |> generate_slugs()
  end

  defp validate_email(changeset) do
    changeset
    |> get_field(:email)
    |> check_email(changeset)
  end

  defp check_email(nil, changeset), do: changeset

  defp check_email(email, changeset) do
    case EmailChecker.valid?(email) do
      true -> changeset
      false -> add_error(changeset, :email, "has invalid format", validation: :format)
    end
  end

  defp generate_uuid(changeset), do: ChangesetHelper.generate_uuid(changeset)

  def generate_slugs(%{valid?: false} = changeset), do: changeset

  def generate_slugs(changeset) do
    Enum.reduce(@sluggified_attr, changeset, &Slugs.generate_slug(&1, &2))
  end
end
