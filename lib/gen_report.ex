defmodule GenReport do
  alias GenReport.Parser

  def build(), do: {:error, "Insira o nome de um arquivo"}

  def build(file_name) do
    file_name

    |> Parser.parse_file()
    |> inner_build()
  end

  defp inner_build(data) do
    %{
      "all_hours" => sum_all_hours(data),
      "hours_per_month" => sum_hours_per_month(data),
      "hours_per_year" => sum_hours_per_year(data)
    }
  end

  def sum_hours_per_year(data) do
    data
    |> Enum.reduce(%{}, fn [name, hours, _,  _, year], acc ->
      case Map.fetch(acc, String.downcase(name)) do
        {:ok, person} ->
          case Map.fetch(person, year) do
            {:ok, year_total} ->
              updated_person =
                Map.put(person, year, year_total + hours)

              acc |> Map.put(String.downcase(name), updated_person)
            _ ->
              updated_person =
                Map.put(person, year, hours)

              acc |> Map.put(String.downcase(name), updated_person)
          end
        _ ->
          Map.put(acc, String.downcase(name), %{year => hours})
      end
    end)
  end

  def sum_hours_per_month(data) do
    data
    |> Enum.reduce(%{}, fn [name, hours, _, month | _], acc ->
      case Map.fetch(acc, String.downcase(name)) do
        {:ok, person} ->
          case Map.fetch(person, String.downcase(month)) do
            {:ok, month_total} ->
              updated_person =
                Map.put(person, String.downcase(month), month_total + hours)

              acc |> Map.put(String.downcase(name), updated_person)
            _ ->
              updated_person =
                Map.put(person, String.downcase(month), hours)

              acc |> Map.put(String.downcase(name), updated_person)
          end
        _ ->
          Map.put(acc, String.downcase(name), %{String.downcase(month) => hours})
      end
    end)
  end

  def sum_all_hours(data) do
    data
    |> Enum.reduce(%{}, fn [name, hours | _], acc ->
      case Map.fetch(acc, String.downcase(name)) do
        {:ok, value} ->
          acc |> Map.put(String.downcase(name), value + hours)
        _ ->
          acc |> Map.put(String.downcase(name), hours)
      end
    end)
  end

end
