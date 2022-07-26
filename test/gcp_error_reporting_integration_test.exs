defmodule GcpErrorReportingIntegrationTest do
  use ExUnit.Case
  doctest GcpErrorReporting

  alias GcpErrorReporting.Reporter

  @goth GcpErrorReportingTest.Goth

  setup do
    {:ok, _} = start_supervised({Goth, name: @goth})
    [project_id: System.fetch_env!("GCP_PROJECT")]
  end

  @tag :integration
  test "report an error to GCP", %{project_id: project_id} do
    error = %RuntimeError{message: "oops"}

    stacktrace = [
      {Foo, :bar, 0, [file: 'foo/bar.ex', line: 123]},
      {Foo.Bar, :baz, 1, [file: 'foo/bar/baz.ex', line: 456]}
    ]

    reporter = %Reporter{goth: @goth, project_id: project_id}
    assert {:ok, _response} = GcpErrorReporting.report_error(error, stacktrace, reporter)
  end
end
