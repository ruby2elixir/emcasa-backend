defmodule Re.Repo.Migrations.AddVilaPompeiaDistrict do
  use Ecto.Migration

  def up do
    Re.Repo.insert(%Re.Addresses.District{
      state: "SP",
      city: "São Paulo",
      name: "Vila Pompéia",
      description: """
      Com a missão de transformar a compra a venda de imóveis, a EmCasa é a melhor opção para encontrar casas e apartamentos localizados em São Paulo, no bairro Vila Pompéia, na região de Perdizes.
      O bairro surgiu no início do século XX como uma próspera região industrial e, mais tarde, abrigando a Igreja de Nossa Senhora do Rosário, o Parque Antártica e o Hospital e Maternidade São Camilo.
      Nos anos 1970 e 1980, a Vila Pompéia chegou a ser chamada de Liverpool Brasileira, devido a forte conexão com a bandas de rock brasileiras.
      Hoje, é um bairro nobre da cidade de São Paulo, localizado na Zona Oeste, e que abriga o Allianz Parque, Bourbon Shopping Pompeia e SESC Pompeia.
      A Vila Pompéia é um bairro muito arborizado, tranquilo, de fácil acesso, com boas opções de comércio e com destaque para a vida cultural local. Com certeza, é o ambiente ideal tanto para jovens, quanto famílias que estão buscando um novo imóvel para morar.
      """
    })
  end

  def down do
    Re.Addresses.District
    |> Re.Repo.get_by(state: "SP", city: "São Paulo", name: "Vila Pompéia")
    |> Re.Repo.delete()
  end
end
