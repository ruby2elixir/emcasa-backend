defmodule Re.SellerLeads.DuplicityChecker do
  require Ecto.Query

  alias Re.{
    Repo,
    SellerLeads.DuplicatedEntity
  }

  alias Ecto.{
    Changeset
  }

  def duplicated?(address, complement) do
    duplicated_entities(address, complement)
    |> duplicated?()
  end

  def duplicated?([]), do: false
  def duplicated?(_), do: true

  def duplicated_entities(address, complement) do
    check_duplicated_entity(address, complement, :seller_leads) ++
      check_duplicated_entity(address, complement, :listings)
  end

  defp check_duplicated_entity(address, complement, entity_name) do
    normalized_complement = normalize_complement(complement)

    address
    |> Repo.preload(entity_name)
    |> Map.get(entity_name)
    |> Enum.filter(fn entity ->
      normalize_complement(entity.complement) == normalized_complement
    end)
    |> Enum.map(fn entity ->
      %{type: entity.__struct__, uuid: entity.uuid}
    end)
  end

  @number_group_regex ~r/(\d)*/

  defp normalize_complement(nil), do: nil

  defp normalize_complement(complement) do
    @number_group_regex
    |> Regex.scan(complement)
    |> Enum.map(fn list -> List.first(list) end)
    |> Enum.filter(fn result -> String.length(result) >= 1 end)
    |> Enum.sort()
    |> Enum.join("")
  end

  def check_duplicity_seller_lead(changeset, nil),
    do: Changeset.put_change(changeset, :duplicated, "unlikely")

  def check_duplicity_seller_lead(changeset, address) do
    complement = Changeset.get_field(changeset, :complement)
    duplicated_entities = duplicated_entities(address, complement)

    changeset =
      changeset
      |> cast_duplicated_entities_for_seller_lead(duplicated_entities)

    case duplicated?(duplicated_entities) do
      true -> Changeset.put_change(changeset, :duplicated, "almost_sure")
      false -> Changeset.put_change(changeset, :duplicated, "maybe")
    end
  end

  defp cast_duplicated_entities_for_seller_lead(changeset, []), do: changeset

  defp cast_duplicated_entities_for_seller_lead(changeset, duplicated_entities) do
    changeset_duplicated =
      duplicated_entities
      |> Enum.map(fn entity -> DuplicatedEntity.changeset(%DuplicatedEntity{}, entity) end)

    changeset
    |> Changeset.put_embed(:duplicated_entities, changeset_duplicated)
  end
end
