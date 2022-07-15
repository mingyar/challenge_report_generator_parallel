defmodule GenReport do
  alias GenReport.Parser

  def build(), do: {:error, "Insira o nome de um arquivo"}

  def build(file_name) do
    file_name
    |> Parser.parse_file()
    |> inner_build()
  end

  def build_from_many(), do: {:error, "Insira uma lista de nomes de um arquivo"}

  def build_from_many(filenames) when not is_list(filenames) do
    {:error, "Insira uma lista de nomes de um arquivo"}
  end

  def build_from_many(filenames) do
      filenames
      |> Task.async_stream(&build/1)
      |> Enum.reduce(report_acc(), fn {:ok, result}, report -> sum_reports(report, result) end)
  end

  defp sum_reports(
    %{
      "all_hours" => all_hours1,
      "hours_per_month" => hours_per_month1,
      "hours_per_year" => hours_per_year1
    },
    %{
      "all_hours" => all_hours2,
      "hours_per_month" => hours_per_month2,
      "hours_per_year" => hours_per_year2
    }
  ) do

    all_hours = merge_maps(all_hours1, all_hours2)
    hours_per_month = merge_maps(hours_per_month1, hours_per_month2)
    hours_per_year = merge_maps(hours_per_year1, hours_per_year2)

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp report_acc,
    do: build_report(%{}, %{}, %{})

  defp merge_maps(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 ->
      inner_merge_maps(value1, value2)
    end)
  end

  defp inner_merge_maps(map1, map2) when is_map(map1) and is_map(map2) do
    merge_maps(map1, map2)
  end

  defp inner_merge_maps(value1, value2), do: value1 + value2

  defp build_report(all_hours, hours_per_month, hours_per_year), do: %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }

  defp inner_build(data),
    do: build_report(sum_all_hours(data), sum_hours_per_month(data), sum_hours_per_year(data))

  defp sum_hours_per_year(data) do
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

  defp sum_hours_per_month(data) do
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

  defp sum_all_hours(data) do
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
