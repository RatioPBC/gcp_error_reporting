if System.get_env("RUN_WITH_GCP") do
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
      error = %RuntimeError{message: "oops"}

      stacktrace = [
        {Foo, :bar, 0, [file: 'foo/bar.ex', line: 123]},
        {Foo.Bar, :baz, 1, [file: 'foo/bar/baz.ex', line: 456]}
      ]

      reporter = %Reporter{goth: @goth, project_id: @project_id}
      assert {:ok, _response} = GcpErrorReporting.report_error(error, stacktrace, reporter)
    end
  end
end
