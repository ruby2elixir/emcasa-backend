defmodule Re.Addresses.Neighborhoods do
  @moduledoc """
  Context for neighborhoods.
  """

  import Ecto.Query

  alias Re.{
    Address,
    Addresses.District,
    Listing,
    Repo,
    Slugs
  }

  @all_query from(
               a in Address,
               join: l in Listing,
               where: l.address_id == a.id and l.status == "active",
               select: a.neighborhood,
               distinct: a.neighborhood
             )

  def all, do: Repo.all(@all_query)

  def get_description(address) do
    case Repo.get_by(District,
           state: address.state,
           city: address.city,
           name: address.neighborhood
         ) do
      nil -> {:error, :not_found}
      description -> {:ok, description}
    end
  end

  def districts, do: Repo.all(from(d in District, where: d.status == "active"))

  def get_district(params) do
    case Repo.get_by(District, params) do
      nil -> {:error, :not_found}
      district -> {:ok, district}
    end
  end

  @doc """
  Temporary mapping to find nearby neighborhood
  """
  def nearby("Botafogo"), do: "Humaitá"
  def nearby("Copacabana"), do: "Ipanema"
  def nearby("Flamengo"), do: "Laranjeiras"
  def nearby("Gávea"), do: "Leblon"
  def nearby("Humaitá"), do: "Botafogo"
  def nearby("Ipanema"), do: "Copacabana"
  def nearby("Itanhangá"), do: "São Conrado"
  def nearby("Jardim Botânico"), do: "Lagoa"
  def nearby("Lagoa"), do: "Humaitá"
  def nearby("Laranjeiras"), do: "Flamengo"
  def nearby("Leblon"), do: "Gávea"
  def nearby("São Conrado"), do: "Itanhangá"

  @covered_neighborhoods [
    %{state: "RJ", neighborhood: "Humaitá", city: "Rio de Janeiro"},
    %{state: "RJ", neighborhood: "Copacabana", city: "Rio de Janeiro"},
    %{state: "RJ", neighborhood: "Botafogo", city: "Rio de Janeiro"},
    %{state: "RJ", neighborhood: "Catete", city: "Rio de Janeiro"},
    %{state: "RJ", neighborhood: "Cosme Velho", city: "Rio de Janeiro"},
    %{state: "RJ", neighborhood: "Flamengo", city: "Rio de Janeiro"},
    %{state: "RJ", neighborhood: "Gávea", city: "Rio de Janeiro"},
    %{state: "RJ", neighborhood: "Ipanema", city: "Rio de Janeiro"},
    %{
      state: "RJ",
      neighborhood: "Jardim Botânico",
      city: "Rio de Janeiro"
    },
    %{state: "RJ", neighborhood: "Joá", city: "Rio de Janeiro"},
    %{state: "RJ", neighborhood: "Lagoa", city: "Rio de Janeiro"},
    %{state: "RJ", neighborhood: "Laranjeiras", city: "Rio de Janeiro"},
    %{state: "RJ", neighborhood: "Leblon", city: "Rio de Janeiro"},
    %{state: "RJ", neighborhood: "Leme", city: "Rio de Janeiro"},
    %{state: "RJ", neighborhood: "São Conrado", city: "Rio de Janeiro"},
    %{state: "RJ", neighborhood: "Urca", city: "Rio de Janeiro"},
    %{state: "SP", neighborhood: "Perdizes", city: "São Paulo"},
    %{state: "SP", neighborhood: "Vila Pompéia", city: "São Paulo"},
    %{state: "SP", neighborhood: "Pompeia", city: "São Paulo"},
    %{state: "SP", neighborhood: "Pinheiros", city: "São Paulo"},
    %{state: "SP", neighborhood: "Sumaré", city: "São Paulo"},
    %{state: "SP", neighborhood: "Sumarezinho", city: "São Paulo"},
    %{state: "SP", neighborhood: "Vila Anglo Brasileira", city: "São Paulo"}
  ]

  def is_covered(neighborhood) do
    @covered_neighborhoods
    |> sluggify_covered_neighborhoods()
    |> MapSet.member?(sluggify_attributes(neighborhood))
  end

  defp sluggify_covered_neighborhoods(covered_neighborhoods) do
    covered_neighborhoods
    |> Enum.map(&sluggify_attributes(&1))
    |> MapSet.new()
  end

  defp sluggify_attributes(neighborhoods) do
    neighborhoods
    |> Map.update!(:city, &Slugs.sluggify(&1))
    |> Map.update!(:neighborhood, &Slugs.sluggify(&1))
    |> Map.update!(:state, &Slugs.sluggify(&1))
  end
end
