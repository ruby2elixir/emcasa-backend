defmodule Re.Addresses.Slugs do

  alias Ecto.Changeset

  def sluggify(string) do
    string
    |> String.split(" ")
    |> Enum.map(&String.normalize(&1, :nfd))
    |> Enum.map(&String.replace(&1, ~r/\W/u, ""))
    |> Enum.join("-")
    |> String.downcase()
  end

  def generate_slug(attr, changeset) do
    slug_content = sluggify_attribute(attr, changeset)

    slug_name = get_slug_name(attr)

    Changeset.change(changeset, [{slug_name, slug_content}])
  end

  defp sluggify_attribute(attr, changeset) do
    changeset
    |> Changeset.get_field(attr)
    |> sluggify()
  end

  defp get_slug_name(attr) do
    attr
    |> to_string()
    |> Kernel.<>("_slug")
    |> String.to_existing_atom()
  end

end
