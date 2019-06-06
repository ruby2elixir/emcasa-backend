defmodule ReIntegrations.Orulo.TagMapper do
  @moduledoc """
  Module to map orulo's tags into our tags.
  """
  alias ReIntegrations.{
    Orulo.BuildingPayload
  }

  def map_tags(%BuildingPayload{} = %{payload: %{"features" => features}}) do
    features
    |> Enum.reduce([], &convert_tag(&1, &2))
    |> Enum.dedup()
  end

  def map_tags(_), do: []

  defp convert_tag("Fitness", acc), do: ["academia" | acc]
  defp convert_tag("Fitness ao ar livre", acc), do: ["academia" | acc]
  defp convert_tag("Churrasqueira condominial", acc), do: ["churrasqueira" | acc]
  defp convert_tag("Espaço gourmet", acc), do: ["espaco-gourmet" | acc]
  defp convert_tag("Jardim", acc), do: ["espaco-verde" | acc]
  defp convert_tag("Praça", acc), do: ["espaco-verde" | acc]
  defp convert_tag("Trilhas e bosque", acc), do: ["espaco-verde" | acc]
  defp convert_tag("Piscina adulto", acc), do: ["piscina" | acc]
  defp convert_tag("Piscina aquecida", acc), do: ["piscina" | acc]
  defp convert_tag("Piscina com raia", acc), do: ["piscina" | acc]
  defp convert_tag("Piscina infantil", acc), do: ["piscina" | acc]
  defp convert_tag("Piscina térmica", acc), do: ["piscina" | acc]
  defp convert_tag("Playground", acc), do: ["playground" | acc]
  defp convert_tag("Quadra futebol sete", acc), do: ["quadra" | acc]
  defp convert_tag("Quadra paddle", acc), do: ["quadra" | acc]
  defp convert_tag("Quadra poliesportiva", acc), do: ["quadra" | acc]
  defp convert_tag("Quadra tênis", acc), do: ["quadra" | acc]
  defp convert_tag("Quadra volei", acc), do: ["quadra" | acc]
  defp convert_tag("Salão de festas", acc), do: ["salao-de-festas" | acc]
  defp convert_tag("Sala de jogos", acc), do: ["salao-de-jogos" | acc]
  defp convert_tag("Sauna", acc), do: ["sauna" | acc]
  defp convert_tag("Terraço", acc), do: ["terraco" | acc]
  defp convert_tag("Terraço coletivo", acc), do: ["terraco" | acc]
  defp convert_tag("Bicicletário", acc), do: ["bicicletario" | acc]
  defp convert_tag("Espaço kids", acc), do: ["brinquedoteca" | acc]
  defp convert_tag("Portaria 24 horas", acc), do: ["portaria-24-horas" | acc]
  defp convert_tag("Portaria", acc), do: ["portaria-horario-comercial" | acc]
  defp convert_tag("Porteiro eletrônico", acc), do: ["portaria-eletronica" | acc]
  defp convert_tag(_, acc), do: acc
end
