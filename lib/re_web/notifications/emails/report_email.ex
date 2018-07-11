defmodule ReWeb.Notifications.ReportEmail do
  @moduledoc """
  Module for building report e-mails
  """
  import Swoosh.Email

  alias Re.{
    Interest,
    Listing,
    User
  }

  @frontend_url Application.get_env(:re, :frontend_url)
  @contato_email "contato@emcasa.com"
  @listing_path "/imoveis/"

  def build_url(path, param) do
    @frontend_url
    |> URI.merge(path)
    |> URI.merge(param)
    |> URI.to_string()
  end

  def monthly_report(%User{name: name, email: email}, listings) do
    {html, text} =
      listings
      |> Enum.map(&report_listing/1)
      |> Enum.reduce({"", ""}, fn {html_fragment, text_fragment}, {html_acc, text_acc} -> {html_acc <> html_fragment, text_acc <> text_fragment} end)

    html_body = """
    Olá, #{name}.<br>
    Estamos enviando esse e-mail com as estatísticas de acesso do seu imóvel desse mês:<br>
    #{html}<br>
    Cheque a página do imóvel para as visualizações totais<br>
    Equipe EmCasa
    """

    text_body = """
    Olá, #{name}.
    Estamos enviando esse e-mail com as estatísticas de acesso do seu imóvel desse mês:
    #{text}
    Cheque a página do imóvel para as visualizações totais
    Equipe EmCasa
    """

    new()
    |> to(email)
    |> from(@contato_email)
    |> subject("Relatório mensal de acesso dos seus imóveis")
    |> html_body(html_body)
    |> text_body(text_body)
  end

  defp report_listing(listing) do
    listing_url = build_url(@listing_path, to_string(listing.id))

    html_fragment = """
      <a href=\"#{listing_url}\">Seu imóvel</a><br>
      Visualizações do imóvel esse mês: #{listing.listings_visualisations_count}<br>
      Visualizações de Tour 3D esse mês: #{listing.tour_visualisations_count}<br>
      Visitas físicas esse mês: #{listing.in_person_visits_count}<br>
      Favoritado esse mês: #{listing.listings_favorites_count}<br>
      Interesses esse mês: #{listing.interests_count}<br>
      <br>
    """

    text_fragment = """
    <a href=\"#{listing_url}\">Seu imóvel</a><br>
    Visualizações do imóvel esse mês: #{listing.listings_visualisations_count}
    Visualizações de Tour 3D esse mês: #{listing.tour_visualisations_count}
    Visitas físicas esse mês: #{listing.in_person_visits_count}
    Favoritado esse mês: #{listing.listings_favorites_count}
    Interesses esse mês: #{listing.interests_count}

    """

    {html_fragment, text_fragment}
  end
end
