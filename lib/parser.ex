defmodule GenReport.Parser do

  def parse_file(filename) do
    filename
    |> File.stream!()
    |> Enum.map(fn line -> parse_line(line) end)
  end

  defp parse_line(line) do
    line
    |> String.trim()
    |> String.split(",")
    |> List.update_at(1, &String.to_integer/1)
    |> List.update_at(2, &String.to_integer/1)
    |> List.update_at(3, &int_to_month/1)
    |> List.update_at(4, &String.to_integer/1)
  end

  defp int_to_month(month) do
      {
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
      }
      |> elem(String.to_integer(month)-1)
  end

end
