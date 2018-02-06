defmodule Re.Stats.Visualizations do
  alias Re.{
    Listing,
    Stats.ListingVisualization,
    Repo,
    User
  }

  def listing(listing, user, _conn) do
    insert(%{listing_id: listing.id, user_id: user.id})
  end

  def listing(listing, nil, conn) do
    insert(%{listing_id: listing.id, details: extract_details(conn)})
  end

  defp insert(params) do
    %ListingVisualization{}
    |> ListingVisualization.changset(params)
    |> Repo.insert()
  end

  @conn_params ~w(remote_ip req_headers)a

  defp extract_details(conn), do: Map.take(conn, @conn_params)
end
