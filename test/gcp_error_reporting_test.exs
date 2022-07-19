defmodule GcpErrorReportingTest do
  use ExUnit.Case
  doctest GcpErrorReporting

  test "report an error to GCP" do
    assert {:ok, _response} = GcpErrorReporting.report_error()
  end
end
