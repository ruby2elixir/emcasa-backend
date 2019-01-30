defmodule Re.Listings.Highlights do
  @moduledoc """
  Context module for listing highlights
  """

  @vivareal_highlights_size_sao_paulo Application.get_env(
                                        :re,
                                        :vivareal_highlights_size_sao_paulo,
                                        0
                                      )
  @vivareal_highlights_size_rio_de_janeiro Application.get_env(
                                             :re,
                                             :vivareal_highlights_size_rio_de_janeiro,
                                             0
                                           )

  @sao_paulo_highlight_size Application.get_env(:re, :zap_highlights_size_sao_paulo, 0)
  @rio_de_janeiro_highlight_size Application.get_env(:re, :zap_highlights_size_rio_de_janeiro, 0)

  @sao_paulo_super_highlight_size Application.get_env(
                                    :re,
                                    :zap_super_highlights_size_sao_paulo,
                                    0
                                  )
  @rio_de_janeiro_super_highlight_size Application.get_env(
                                         :re,
                                         :zap_super_highlights_size_rio_de_janeiro,
                                         0
                                       )

  alias Re.{
    Listings.Queries,
    Repo
  }

  def get_highlight_listing_ids(query, params \\ %{}) do
    get_highlights(query, params)
    |> Enum.map(& &1.id)
  end

  defp get_highlights(query, params) do
    order = %{order_by: [%{field: :updated_at, type: :desc}]}

    query
    |> Queries.order_by(order)
    |> Queries.limit(params)
    |> Queries.offset(params)
    |> Repo.all()
  end

  def get_vivareal_highlights_size(city),
    do: get_highlights_size(:vivareal_highlight, city)

  def get_zap_highlights_size(city),
    do: get_highlights_size(:zap_highlight, city)

  def get_zap_super_highlights_size(city),
    do: get_highlights_size(:zap_super_highlight, city)

  defp get_highlights_size(:vivareal_highlight, "sao-paulo"),
    do: @vivareal_highlights_size_sao_paulo

  defp get_highlights_size(:vivareal_highlight, "rio-de-janeiro"),
    do: @vivareal_highlights_size_rio_de_janeiro

  defp get_highlights_size(:zap_highlight, "sao-paulo"), do: @sao_paulo_highlight_size

  defp get_highlights_size(:zap_highlight, "rio-de-janeiro"), do: @rio_de_janeiro_highlight_size

  defp get_highlights_size(:zap_super_highlight, "sao-paulo"),
    do: @sao_paulo_super_highlight_size

  defp get_highlights_size(:zap_super_highlight, "rio-de-janeiro"),
    do: @rio_de_janeiro_super_highlight_size

  defp get_highlights_size(_, _), do: 0
end
