defmodule GcpErrorReportingTest do
  use ExUnit.Case
  doctest GcpErrorReporting

  alias GcpErrorReporting.Reporter

  @goth GcpErrorReportingTest.Goth
  @project_id System.fetch_env!("GCP_PROJECT")

  setup do
    {:ok, _} = start_supervised({Goth, name: @goth})
    :ok
  end

  test "report an error to GCP" do
    reporter = %Reporter{goth: @goth, project_id: @project_id}
    assert {:ok, _response} = GcpErrorReporting.report_error(reporter)
  end
end
