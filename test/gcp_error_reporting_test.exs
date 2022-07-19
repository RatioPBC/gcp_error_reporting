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
    message = """
    Pat's super duper cool error

    path/to/prog.ex:2:in `My.Mod.a'
    path/to/prog.ex:6:in `My.Mod.b'
    path/to/prog.ex:10:in `My.Mod.c'
    """

    reporter = %Reporter{goth: @goth, project_id: @project_id}
    assert {:ok, _response} = GcpErrorReporting.report_error(message, reporter)
  end
end
