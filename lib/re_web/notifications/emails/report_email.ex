defmodule ReWeb.Notifications.ReportEmail do
  use Phoenix.Swoosh, view: ReWeb.Notifications.ReportView, layout: {ReWeb.LayoutView, :email}

  @frontend_url Application.get_env(:re, :frontend_url)
  @contato_email "contato@emcasa.com"
  @listing_path "/imoveis/"

  def monthly_report(user, listings) do
    listings = Enum.map(listings, &put_url/1)

    new()
    |> to(user.email)
    |> from(@contato_email)
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
