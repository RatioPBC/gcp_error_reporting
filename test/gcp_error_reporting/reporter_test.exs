defmodule GcpErrorReporting.ReporterTest do
  use ExUnit.Case

  alias GcpErrorReporting.Reporter

  alias GoogleApi.CloudErrorReporting.V1beta1.Model.ErrorContext
  alias GoogleApi.CloudErrorReporting.V1beta1.Model.ReportedErrorEvent
  alias GoogleApi.CloudErrorReporting.V1beta1.Model.ServiceContext
  alias GoogleApi.CloudErrorReporting.V1beta1.Model.SourceReference

  describe "format_error" do
    test "a runtime error with message" do
      error = %RuntimeError{message: "oops"}
      stacktrace = [
        {Foo, :bar, 0, [file: 'foo/bar.ex', line: 123]},
        {Foo.Bar, :baz, 1, [file: 'foo/bar/baz.ex', line: 456]}
      ]

      assert Reporter.format_error(error, stacktrace) ==
        """
        ** (RuntimeError) oops
        foo/bar.ex:123:in `Foo.bar/0'
        foo/bar/baz.ex:456:in `Foo.Bar.baz/1'
        """
    end
  end

  describe "error_event" do
    setup do
      %{
        error: %RuntimeError{message: "oops"},
        stacktrace: [
          {Foo, :bar, 0, [file: 'foo/bar.ex', line: 123]},
          {Foo.Bar, :baz, 1, [file: 'foo/bar/baz.ex', line: 456]}
        ]
      }
    end

    test "basic config", %{error: error, stacktrace: stacktrace} do
      reporter = %Reporter{}
      message =
        """
        ** (RuntimeError) oops
        foo/bar.ex:123:in `Foo.bar/0'
        foo/bar/baz.ex:456:in `Foo.Bar.baz/1'
        """

      assert Reporter.error_event(error, stacktrace, reporter) == %ReportedErrorEvent{
        message: message
      }
    end

    test "with service" do
      reporter = %Reporter{service: "foo"}

      assert Reporter.error_event("foo error", reporter) == %ReportedErrorEvent{
        message: "foo error",
        serviceContext: %ServiceContext{service: "foo"}
      }
    end

    test "with service_version" do
      reporter = %Reporter{service_version: "main"}

      assert Reporter.error_event("foo error", reporter) == %ReportedErrorEvent{
        message: "foo error",
        serviceContext: %ServiceContext{version: "main"}
      }
    end

    test "with service and service_version" do
      reporter = %Reporter{service: "foo", service_version: "main"}

      assert Reporter.error_event("foo error", reporter) == %ReportedErrorEvent{
        message: "foo error",
        serviceContext: %ServiceContext{service: "foo", version: "main"}
      }
    end

    test "with sources" do
      reporter = %Reporter{sources: [[repository: "https://www.github.com/tba", revision: "main"], [repository: "https://www.gitlab.com/mirror"], [revision: "foo"]]}

      assert Reporter.error_event("foo error", reporter) == %ReportedErrorEvent{
        message: "foo error",
        context: %ErrorContext{
          sourceReferences: [
            %SourceReference{repository: "https://www.github.com/tba", revisionId: "main"},
            %SourceReference{repository: "https://www.gitlab.com/mirror"},
            %SourceReference{revisionId: "foo"},
          ]
        }
      }
    end
  end
end
