defmodule GcpErrorReporting.ReporterTest do
  use ExUnit.Case

  alias GcpErrorReporting.Reporter

  alias GoogleApi.CloudErrorReporting.V1beta1.Model.ErrorContext
  alias GoogleApi.CloudErrorReporting.V1beta1.Model.ReportedErrorEvent
  alias GoogleApi.CloudErrorReporting.V1beta1.Model.ServiceContext
  alias GoogleApi.CloudErrorReporting.V1beta1.Model.SourceLocation
  alias GoogleApi.CloudErrorReporting.V1beta1.Model.SourceReference

  describe "error_event" do
    setup do
      %{
        error: %RuntimeError{message: "oops"},
        stacktrace: [
          {Foo, :bar, 0, [file: 'foo/bar.ex', line: 123]},
          {Foo.Bar, :baz, 1, [file: 'foo/bar/baz.ex', line: 456]}
        ],
        message: """
        RuntimeError in Foo.bar/0 (foo/bar.ex:123)
        foo/bar.ex:123:in `Foo.bar/0'
        foo/bar/baz.ex:456:in `Foo.Bar.baz/1'
        --
        ** (RuntimeError) oops
        """,
        source_location: %SourceLocation{
          filePath: "foo/bar.ex",
          functionName: "Foo.bar/0",
          lineNumber: 123
        }
      }
    end

    test "basic config", %{
      error: error,
      stacktrace: stacktrace,
      message: message,
      source_location: source_location
    } do
      reporter = %Reporter{}

      assert Reporter.error_event(error, stacktrace, reporter) == %ReportedErrorEvent{
               message: message,
               context: %ErrorContext{
                 reportLocation: source_location
               }
             }
    end

    test "erlang error" do
      reporter = %Reporter{}

      error = :undef

      stacktrace = [
        {Foo, :bar, [123, 456], []},
        {Foo, :bar, 2, [file: 'foo/bar.ex', line: 123]},
        {Foo.Bar, :baz, 1, [file: 'foo/bar/baz.ex', line: 456]}
      ]

      message = """
      UndefinedFunctionError in Foo.bar/2 (foo/bar.ex:123)
      foo/bar.ex:123:in `Foo.bar/2'
      foo/bar/baz.ex:456:in `Foo.Bar.baz/1'
      --
      ** (UndefinedFunctionError) function Foo.bar/2 is undefined (module Foo is not available)
      """

      assert Reporter.error_event(error, stacktrace, reporter) == %ReportedErrorEvent{
               message: message,
               context: %ErrorContext{
                 reportLocation: %SourceLocation{
                   filePath: "foo/bar.ex",
                   functionName: "Foo.bar/2",
                   lineNumber: 123
                 }
               }
             }
    end

    test "with service", %{
      error: error,
      stacktrace: stacktrace,
      message: message,
      source_location: source_location
    } do
      reporter = %Reporter{service: "foo"}

      assert Reporter.error_event(error, stacktrace, reporter) == %ReportedErrorEvent{
               message: message,
               serviceContext: %ServiceContext{service: "foo"},
               context: %ErrorContext{reportLocation: source_location}
             }
    end

    test "with service_version", %{
      error: error,
      stacktrace: stacktrace,
      message: message,
      source_location: source_location
    } do
      reporter = %Reporter{service_version: "main"}

      assert Reporter.error_event(error, stacktrace, reporter) == %ReportedErrorEvent{
               message: message,
               serviceContext: %ServiceContext{version: "main"},
               context: %ErrorContext{reportLocation: source_location}
             }
    end

    test "with sources", %{
      error: error,
      stacktrace: stacktrace,
      message: message,
      source_location: source_location
    } do
      reporter = %Reporter{
        sources: [[repository: "https://www.github.com/tba", revision: "main"]]
      }

      assert Reporter.error_event(error, stacktrace, reporter) == %ReportedErrorEvent{
               message: message,
               context: %ErrorContext{
                 sourceReferences: [
                   %SourceReference{repository: "https://www.github.com/tba", revisionId: "main"}
                 ],
                 reportLocation: source_location
               }
             }
    end

    test "complete config", %{
      error: error,
      stacktrace: stacktrace,
      message: message,
      source_location: source_location
    } do
      reporter = %Reporter{
        service: "foo",
        service_version: "main",
        sources: [
          [repository: "https://www.github.com/tba", revision: "main"],
          [repository: "https://www.gitlab.com/mirror"],
          [revision: "foo"]
        ]
      }

      assert Reporter.error_event(error, stacktrace, reporter) == %ReportedErrorEvent{
               message: message,
               serviceContext: %ServiceContext{service: "foo", version: "main"},
               context: %ErrorContext{
                 reportLocation: source_location,
                 sourceReferences: [
                   %SourceReference{repository: "https://www.github.com/tba", revisionId: "main"},
                   %SourceReference{repository: "https://www.gitlab.com/mirror"},
                   %SourceReference{revisionId: "foo"}
                 ]
               }
             }
    end
  end
end
