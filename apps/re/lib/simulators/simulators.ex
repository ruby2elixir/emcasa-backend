defmodule Re.Simulators do
  alias Re.Simulators.Credipronto.Params

  alias ReIntegrations.Credipronto.{
    Client,
    Mapper
  }

  defdelegate authorize(action, user, params), to: __MODULE__.Policy

  def simulate(params) do
    with %{valid?: true} <- Params.changeset(%Params{}, params),
         query <- map_query(params),
         {:ok, %{body: body}} <- Client.get(query),
         {:ok, payload} <- Poison.decode(body) do
      {:ok, Mapper.payload_in(payload)}
    else
      %{valid?: false} = changeset -> {:error, changeset}
      error -> error
    end
  end

  defp map_query(params) do
    params
    |> Map.delete(:__struct__)
    |> Map.delete(:__meta__)
    |> Enum.into(%{})
    |> Mapper.query_out()
  end
end
