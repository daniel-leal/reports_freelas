defmodule ReportsFreelasParserTest do
  use ExUnit.Case

  alias ReportsFreelas.Parser

  describe "parse_file/1" do
    test "Returns formatted list when given csv" do
      filename = "report_test.csv"

      expected_response = [
        [:daniele, 7, "29", :abril, "2018"],
        [:mayk, 4, "9", :dezembro, "2019"],
        [:daniele, 5, "27", :dezembro, "2016"],
        [:mayk, 1, "2", :dezembro, "2017"],
        [:giuliano, 3, "13", :fevereiro, "2017"],
        [:cleiton, 1, "22", :junho, "2020"],
        [:giuliano, 6, "18", :fevereiro, "2019"],
        [:jakeliny, 8, "18", :julho, "2017"],
        [:joseph, 3, "17", :março, "2017"],
        [:jakeliny, 6, "23", :março, "2019"]
      ]

      response =
        filename
        |> Parser.parse_file()
        |> Enum.map(& &1)

      assert expected_response == response
    end
  end
end
