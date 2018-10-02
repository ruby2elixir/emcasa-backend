defmodule ReIntegrations.Notifications.Emails.Report do
  @moduledoc """
  Module for building report emails
  """
  use Phoenix.Swoosh,
    view: ReIntegrations.Notifications.ReportView,
    layout: {ReWeb.LayoutView, :email}

  @frontend_url Application.get_env(:re, :frontend_url)
  @contato_email "contato@emcasa.com"
  @listing_path "/imoveis/"
  @reply_to Application.get_env(:re, :reply_to)

  def monthly_report(user, listings) do
    listings = Enum.map(listings, &put_url/1)

    new()
    |> to(user.email)
    |> from(@contato_email)
    |> reply_to(@reply_to)
    |> subject("Relatório mensal de acesso dos seus imóveis")
    |> render_body("monthly_report.html", %{user: user, listings: listings})
  end

  def build_url(path, param) do
    @frontend_url
    |> URI.merge(path)
    |> URI.merge(param)
    |> URI.to_string()
  end

  defp put_url(listing) do
    url = build_url(@listing_path, to_string(listing.id))

    Map.put(listing, :url, url)
  end
end
