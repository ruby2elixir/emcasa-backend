defmodule Re.Listings do

  import Ecto
  import Ecto.Query

  alias Re.{
    Listing,
    Image,
    Repo
  }

  def all do
    Repo.all(from l in Listing,
      where: l.is_active == true,
      order_by: [desc: l.score],
      order_by: [asc: l.matterport_code])
      |> Repo.preload(:address)
      |> Repo.preload([images: (from i in Image, order_by: i.position)])
  end

  def get(id) do
    listing =
      from(l in Listing, where: l.is_active == true)
      |> Repo.get!(id)
      |> Repo.preload(:address)
      |> Repo.preload([images: (from i in Image, order_by: i.position)])
  end

  def insert(listing_params, address_id) do
    %Listing{}
    |> Listing.changeset(Map.put(listing_params, "address_id", address_id))
    |> Repo.insert()
  end

  def update(listing, listing_params, address_id) do
    listing
    |> Listing.changeset(listing_params)
    |> Ecto.Changeset.change(address_id: address_id)
    |> Repo.update()
  end

end
