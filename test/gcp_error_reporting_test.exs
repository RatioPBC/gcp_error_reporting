defmodule GcpErrorReportingTest do
  use ExUnit.Case
  doctest GcpErrorReporting

  @goth GcpErrorReportingTest.Goth

  setup do
    {:ok, _} = start_supervised({Goth, name: @goth})
    :ok
  end

  test "report an error to GCP" do
    assert {:ok, _response} = GcpErrorReporting.report_error(@goth)
  end
end
