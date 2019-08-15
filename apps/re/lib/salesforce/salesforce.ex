defmodule Re.Salesforce do
  @moduledoc """
  Context module for salesforce
  """

  alias Re.Salesforce.Client

  def get_opportunity(id), do: get_entity(id, :Opportunity)

  defp get_entity(id, type) do
    with {:ok, %{status_code: 200, body: body}} <- Client.get(id, type),
         {:ok, data} <- Jason.decode(body) do
      {:ok, data}
    else
      {:ok, %{status_code: _status_code} = data} -> {:error, data}
      error -> error
    end
  end
end
