defmodule GenParallelReportTest do
  use ExUnit.Case

  alias GenReport
  alias GenReport.Support.ReportFixture

  @file_names ["part_1.csv", "part_2.csv", "part_3.csv"]

  describe "build_from_many/1" do
    test "When passing a list of files names return a report" do
      response = GenReport.build_from_many(@file_names)

      assert response == ReportFixture.build()
    end

    test "When no filenames was given, returns an error" do
      response = GenReport.build_from_many()

      assert response == {:error, "Insira uma lista de nomes de um arquivo"}
    end

    test "When a filename is given, returns an error" do
      response = GenReport.build_from_many("report.csv")

      assert response == {:error, "Insira uma lista de nomes de um arquivo"}
    end
  end
end
