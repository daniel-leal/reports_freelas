defmodule ReportsFreelas do
  alias ReportsFreelas.Parser

  @freelas [
    "cleiton",
    "daniele",
    "danilo",
    "diego",
    "giuliano",
    "jakeliny",
    "joseph",
    "mayk",
    "rafael",
    "vinicius"
  ]

  @available_months [
    "janeiro",
    "fevereiro",
    "março",
    "abril",
    "maio",
    "junho",
    "julho",
    "agosto",
    "setembro",
    "outubro",
    "novembro",
    "dezembro"
  ]

  def build(), do: {:error, "Insira o nome do arquivo"}

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(report_acc(), fn line, report -> total(line, report) end)
  end

  def build_from_many(), do: {:error, "Insira os nomes dos arquivos"}

  def build_from_many(filenames) do
    filenames
    |> Task.async_stream(&build/1)
    |> Enum.reduce(report_acc(), fn {:ok, result}, report -> sum_reports(report, result) end)
  end

  defp total(line, report) do
    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    } = report

    all_hours = sum_all_hours(line, all_hours)
    hours_per_month = sum_hours_per_month(line, hours_per_month)
    hours_per_year = sum_hours_per_year(line, hours_per_year)

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp sum_reports(report, result) do
    %{
      "all_hours" => all_hours1,
      "hours_per_month" => hours_per_month1,
      "hours_per_year" => hours_per_year1
    } = report

    %{
      "all_hours" => all_hours2,
      "hours_per_month" => hours_per_month2,
      "hours_per_year" => hours_per_year2
    } = result

    all_hours = merge_maps(all_hours1, all_hours2)
    hours_per_month = merge_nested_maps(hours_per_month1, hours_per_month2)
    hours_per_year = merge_nested_maps(hours_per_year1, hours_per_year2)

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

  def sum_map_values(map, %{key: key, value: value}) do
    Map.put(map, key, map[key] + value)
  end

  defp merge_maps(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 -> value1 + value2 end)
  end

  defp merge_nested_maps(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 -> merge_maps(value1, value2) end)
  end

  defp report_acc do
    all_hours = Enum.into(@freelas, %{}, &{&1, 0})

    months = Enum.into(@available_months, %{}, &{&1, 0})
    hours_per_month = Enum.into(@freelas, %{}, &{&1, months})

    years = Enum.into(2016..2020, %{}, &{&1, 0})
    hours_per_year = Enum.into(@freelas, %{}, &{&1, years})

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp build_report(all_hours, hours_per_month, hours_per_year) do
    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end
end
