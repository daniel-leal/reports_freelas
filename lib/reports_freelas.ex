defmodule ReportsFreelas do
  alias ReportsFreelas.Parser

  @freelas [
    :cleiton,
    :daniele,
    :danilo,
    :diego,
    :giuliano,
    :jakeliny,
    :joseph,
    :mayk,
    :rafael,
    :vinicius
  ]

  @available_months [
    :janeiro,
    :fevereiro,
    :março,
    :abril,
    :maio,
    :junho,
    :julho,
    :agosto,
    :setembro,
    :outubro,
    :novembro,
    :dezembro
  ]

  @available_years ["2016", "2017", "2018", "2019", "2020"]

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(report_acc(), fn line, report -> total(line, report) end)
  end

  defp total(line, %{
         all_hours: all_hours,
         hours_per_month: hours_per_month,
         hours_per_year: hours_per_year
       }) do
    all_hours = sum_all_hours(line, all_hours)
    hours_per_month = sum_hours_per_month(line, hours_per_month)
    hours_per_year = sum_hours_per_year(line, hours_per_year)

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp sum_all_hours([name, hour, _, _, _], all_hours) do
    Map.put(all_hours, name, all_hours[name] + hour)
  end

  defp sum_hours_per_month([name, hour, _, month, _], hours_per_month) do
    Map.put(
      hours_per_month,
      name,
      Map.put(hours_per_month[name], month, hours_per_month[name][month] + hour)
    )
  end

  defp sum_hours_per_year([name, hour, _, _, year], hours_per_year) do
    Map.put(
      hours_per_year,
      name,
      Map.put(hours_per_year[name], year, hours_per_year[name][year] + hour)
    )
  end

  defp report_acc do
    all_hours = Enum.into(@freelas, %{}, &{&1, 0})

    months = Enum.into(@available_months, %{}, &{&1, 0})
    hours_per_month = Enum.into(@freelas, %{}, &{&1, months})

    years = Enum.into(@available_years, %{}, &{&1, 0})
    hours_per_year = Enum.into(@freelas, %{}, &{&1, years})

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp build_report(all_hours, hours_per_month, hours_per_year) do
    %{
      all_hours: all_hours,
      hours_per_month: hours_per_month,
      hours_per_year: hours_per_year
    }
  end
end
