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

  @zap_highlights_size_sao_paulo Application.get_env(:re, :zap_highlights_size_sao_paulo, 0)
  @zap_super_highlights_size_sao_paulo Application.get_env(
                                         :re,
                                         :zap_super_highlights_size_sao_paulo,
                                         0
                                       )
  @zap_highlights_size_rio_de_janeiro Application.get_env(
                                        :re,
                                        :zap_highlights_size_rio_de_janeiro,
                                        0
                                      )
  @zap_super_highlights_size_rio_de_janeiro Application.get_env(
                                              :re,
                                              :zap_super_highlights_size_rio_de_janeiro,
                                              0
                                            )

  @imovelweb_super_highlights_size_sao_paulo Application.get_env(
                                               :re,
                                               :imovelweb_super_highlights_size_sao_paulo,
                                               0
                                             )
  @imovelweb_highlights_size_sao_paulo Application.get_env(
                                         :re,
                                         :imovelweb_highlights_size_sao_paulo,
                                         0
                                       )
  @imovelweb_super_highlights_size_rio_de_janeiro Application.get_env(
                                                    :re,
                                                    :imovelweb_super_highlights_size_rio_de_janeiro,
                                                    0
                                                  )
  @imovelweb_highlights_size_rio_de_janeiro Application.get_env(
                                              :re,
                                              :imovelweb_highlights_size_rio_de_janeiro,
                                              0
                                            )

  alias Re.{
    Listings.Highlights.Scores,
    Listings.Queries,
    Repo
  }

  def get_highlight_listing_ids(params \\ %{}) do
    params
    |> get_highlights()
    |> Enum.map(& &1.id)
  end

  defp get_highlights(%{page_size: page_size} = params) do
    params
    |> get_all_highlights()
    |> Enum.take(page_size)
  end

  defp get_highlights(params) do
    get_all_highlights(params)
  end

  defp get_all_highlights(params) do
    Queries.active()
    |> Scores.filter_with_profile_score(Map.get(params, :filters, %{}))
    |> Queries.preload_relations([:address])
    |> Repo.all()
    |> Scores.order_highlights_by_scores()
    |> Enum.drop(Map.get(params, :offset, 0))
  end

  def get_vivareal_highlights_size(city),
    do: get_highlights_size(:vivareal_highlight, city)

  def get_zap_highlights_size(city),
    do: get_highlights_size(:zap_highlight, city)

  def get_zap_super_highlights_size(city),
    do: get_highlights_size(:zap_super_highlight, city)

  def get_imovelweb_highlights_size(city), do: get_highlights_size(:imovelweb_highlight, city)

  def get_imovelweb_super_highlights_size(city),
    do: get_highlights_size(:imovelweb_super_highlight, city)

  defp get_highlights_size(:vivareal_highlight, "sao-paulo"),
    do: @vivareal_highlights_size_sao_paulo

  defp get_highlights_size(:vivareal_highlight, "rio-de-janeiro"),
    do: @vivareal_highlights_size_rio_de_janeiro

  defp get_highlights_size(:zap_highlight, "sao-paulo"), do: @zap_highlights_size_sao_paulo

  defp get_highlights_size(:zap_highlight, "rio-de-janeiro"),
    do: @zap_highlights_size_rio_de_janeiro

  defp get_highlights_size(:zap_super_highlight, "sao-paulo"),
    do: @zap_super_highlights_size_sao_paulo

  defp get_highlights_size(:zap_super_highlight, "rio-de-janeiro"),
    do: @zap_super_highlights_size_rio_de_janeiro

  defp get_highlights_size(:imovelweb_highlight, "sao-paulo"),
    do: @imovelweb_highlights_size_sao_paulo

  defp get_highlights_size(:imovelweb_highlight, "rio-de-janeiro"),
    do: @imovelweb_highlights_size_rio_de_janeiro

  defp get_highlights_size(:imovelweb_super_highlight, "sao-paulo"),
    do: @imovelweb_super_highlights_size_sao_paulo

  defp get_highlights_size(:imovelweb_super_highlight, "rio-de-janeiro"),
    do: @imovelweb_super_highlights_size_rio_de_janeiro

  defp get_highlights_size(_, _), do: 0
end
