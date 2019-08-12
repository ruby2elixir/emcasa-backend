defmodule ReIntegrations.Salesforce.Payload.Lead do
  @moduledoc """
  Module for validating salesforce lead entity
  """
  use Ecto.Schema

  import Ecto.Changeset

  import EctoEnum

  @primary_key {:id, :string, []}

  @doc """
  Maps salesforce fields to atoms for internal use
  """
  defenum(Schema,
    last_name: "LastName",
    location: "Unidade_de_Negocio__c",
    street: "Street",
    neighborhood: "Bairro__c",
    city: "City",
    state: "State",
    email: "Email",
    interest_realty_id: "Imovel_de_Interesse__c",
    source: "LeadSource",
    phone: "MobilePhone",
    full_name: "Nome_Completo2__c",
    budget: "Range_de_Compra__c",
    area: "Area_do_Imovel__c",
    evaluation: "Avaliacao_do_Imovel__c",
    realty_postal_code: "CEP__c",
    realty_city: "Cidade_do_Imovel__c",
    complemenet: "Complemento__c",
    tour_data: "Data_Tour__c",
    inserted_at: "Data_de_Criacao_do_Lead__c",
    realty_state: "Estado_do_Imovel__c",
    realty_bathrooms: "Numero_de_Banheiros__c",
    realty_rooms: "Numero_de_Quartos__c",
    realty_garage_spots: "Numero_de_Vagas__c",
    realty_street_number: "Numero_do_Imovel__c",
    realty_street: "Rua_do_Imovel__c",
    realty_suites: "Suites__c",
    realty_type: "Tipo_do_Imovel__c",
    maintenance_fee: "Valor_do_Condominio__c",
    price: "Valor_do_Imovel__c",
    postal_code: "PostalCode",
    record_type_id: "RecordTypeId",
    type: "Tipo_de_Lead__c",
    uuid: "uuid__c"
  )

  defenum(Type,
    seller: "Venda",
    buyer: "Compra"
  )

  schema "salesforce_lead" do
    field :last_name, :string
    field :location, :string
    field :street, :string
    field :neighborhood, :string
    field :city, :string
    field :state, :string
    field :email, :string
    field :interest_realty_id, :string
    field :source, :string
    field :phone, :string
    field :full_name, :string
    field :budget, :string
    field :area, :integer
    field :evaluation, :boolean
    field :realty_postal_code, :string
    field :realty_city, :string
    field :complemenet, :string
    field :tour_data, :naive_datetime
    field :inserted_at, :utc_datetime
    field :realty_state, :string
    field :realty_bathrooms, :integer
    field :realty_rooms, :integer
    field :realty_garage_spots, :integer
    field :realty_street_number, :string
    field :realty_street, :string
    field :realty_suites, :integer
    field :realty_type, :string
    field :maintenance_fee, :float
    field :price, :integer
    field :postal_code, :string
    field :record_type_id, :string
    field :type, Type
    field :uuid, :string
  end

  @optional ~w(location street neighborhood city state email interest_realty_id
               source phone full_name budget area evaluation realty_postal_code realty_city
               complemenet tour_data inserted_at realty_state realty_bathrooms realty_rooms
               realty_garage_spots realty_street_number realty_street realty_suites realty_type
               maintenance_fee price postal_code record_type_id type uuid)a
  @required ~w(last_name)a
  @params @optional ++ @required

  def validate(params) do
    %__MODULE__{}
    |> changeset(params)
    |> case do
      %{valid?: true} = changeset -> {:ok, apply_changes(changeset)}
      changeset -> {:error, :invalid_input, params, changeset}
    end
  end

  defp changeset(struct, params) do
    struct
    |> cast(params, @params)
    |> validate_required(@required)
  end
end

defimpl Jason.Encoder, for: ReIntegrations.Salesforce.Payload.Lead do
  alias ReIntegrations.Salesforce.Payload.Lead

  def encode(value, opts) do
    keys = Keyword.keys(Lead.Schema.__enum_map__())

    value
    |> Map.take(keys)
    |> Map.drop([:id])
    |> Enum.into(%{}, &dump_field/1)
    |> Jason.Encode.map(opts)
  end

  defp dump_field({:type, enum}) when is_atom(enum),
    do: with({:ok, value} <- Lead.Type.dump(enum), do: dump_field({:type, value}))

  defp dump_field({key, value}),
    do: with({:ok, field} <- Lead.Schema.dump(key), do: {field, value})
end
