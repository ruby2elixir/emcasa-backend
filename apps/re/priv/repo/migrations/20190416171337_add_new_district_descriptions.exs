defmodule Re.Repo.Migrations.AddNewDistrictDescriptions do
  use Ecto.Migration

  alias Re.{
    Addresses.District,
    Repo
  }

  @districts [
    %District{
      state: "SP",
      city: "São Paulo",
      name: "Vila Anglo Brasileira",
      description: """
      Com a missão de transformar a compra a venda de imóveis, a EmCasa é a melhor opção para encontrar casas e apartamentos localizados em São Paulo, na região Vila Anglo Brasileira.
      A Vila Anglo Brasileira está situada em uma das melhores regiões para se morar na capital paulista, a Zona Oeste.
      É considerado um bairro de classe média e classe média-alta e é bastante conhecido por seu caráter residencial e pela grande concentração de casas.
      A Vila Anglo Brasileira é também muito arborizada e abriga parte da praça Vicente Tramonte Garcia.
      Definitivamente, é mais um destaque na Zona Oeste da capital paulista, sendo visto como uma ótima opção para a compra e venda de imóveis na região.
      """
    },
    %District{
      state: "SP",
      city: "São Paulo",
      name: "Sumarezinho",
      description: """
      Com a missão de transformar a compra a venda de imóveis, a EmCasa é a melhor opção para encontrar casas e apartamentos localizados em São Paulo, no bairro Sumarezinho.
      O Sumarezinho está situado em uma das melhores regiões para se morar na capital paulista, a Zona Oeste.
      Está localizado próximo a importantes bairros como Pinheiros e Sumaré, o que faz dele um bairro privilegiado.
      Os apartamentos e casas da região são conhecidos pelo excelente custo-benefício. Ou seja, comprar um imóvel em Sumarezinho é sinônimo de ter excelentes benefícios proporcionados pelo bairro a um ótimo valor de mercado.
      """
    },
    %District{
      state: "SP",
      city: "São Paulo",
      name: "Sumaré",
      description: """
      Com a missão de transformar a compra a venda de imóveis, a EmCasa é a melhor opção para encontrar casas e apartamentos localizados em São Paulo, no bairro Sumaré.
      O Sumaré está stuado em uma das áreas mais altas da capital paulista, conhecida como Espigão da Paulista e abriga diversos estúdios de emissoras de TV. É, hoje, juntamente com outros bairros de Zona Oeste de São Paulo, um dos mais desejados por quem quer morar bem.
      Super arborizado, o bairro é tombado pelo Conselho de Defesa do Patrimônio Histórico e tem o Santuário Nossa Senhora do Rosário de Fátima como um dos seus símbolos.
      Outra característica positiva é o fácil acesso às grandes avenidas e também ao transporte público, tanto para linhas de ônibus, quanto metrô.
      O grande diferencial do bairro Sumaré é a capacidade de unir tranquilidade, segurança e um ambiente arborizado e pouco verticalizado com o fácil acesso às principal regiões da capital Paulista.
      """
    },
    %District{
      state: "SP",
      city: "São Paulo",
      name: "Pinheiros",
      description: """
      Com a missão de transformar a compra a venda de imóveis, a EmCasa é a melhor opção para encontrar casas e apartamentos localizados em São Paulo, na região de Pinheiros.
      O bairro é considerado um dos mais legais da cidade, responsável por lançar tendências e conhecido por seus points gastronômicos e suas boutiques.
      Com uma localização privilegiada, o bairro Pinheiros está situado na Zona Oeste de São Paulo. Faz divisa com os bairros Jardim Paulistano, Vila Madalena, Alto de Pinheiros, Cidade Jardim e City Butantã. A região também está localizada próxima de importantes vias como as Avenidas Brigadeiro Faria Lima, Rebouças, Eusébio Matoso e Nações Unidas, além da Marginal Pinheiros.
      Mais do que uma excelente localização, Pinheiros está repleto de soluções e boas opções para quem mora ou frequenta o bairro. São diversos Parques, como o Villa-Lobos e a praça Panamericana. No segmento da saúde, temos o Hospital das Clínicas e, na área da educação grandes universidades também estão presentes: UNIP, FMU e FESP. Para finalizar, o bairro ainda abriga os Shoppings Eldorado e Iguatemi.
      São essas e outras características que tornam Pinheiros, uma das regiões mais cobiçadas da cidade de São Paulo.
      """
    }
  ]

  def up do
    Enum.each(@districts, &Repo.insert!/1)
  end

  def down do
    delete_district("SP", "São Paulo", "Vila Anglo Brasileira")
    delete_district("SP", "São Paulo", "Sumarezinho")
    delete_district("SP", "São Paulo", "Sumaré")
    delete_district("SP", "São Paulo", "Pinheiros")
  end

  defp delete_district(state, city, name) do
    District
    |> Repo.get_by(state: state, city: city, name: name)
    |> case do
      nil -> :do_nothing
      district -> Repo.delete(district)
    end
  end
end
