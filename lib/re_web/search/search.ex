defmodule ReWeb.Search do
  @spec build_index() :: GenServer.cast()
  def build_index(), do: GenServer.cast(__MODULE__.Server, :build_index)

  @spec cleanup_index() :: GenServer.cast()
  def cleanup_index(), do: GenServer.cast(__MODULE__.Server, :cleanup_index)

  @spec put_document(Listing.t()) :: GenServer.cast()
  def put_document(listing), do: GenServer.cast(__MODULE__.Server, {:put_document, listing})

  @spec delete_document(Listing.t()) :: GenServer.cast()
  def delete_document(listing), do: GenServer.cast(__MODULE__.Server, {:delete_document, listing})
end
