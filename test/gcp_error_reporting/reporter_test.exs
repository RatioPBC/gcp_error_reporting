defmodule GcpErrorReporting.ReporterTest do
  use ExUnit.Case

  alias GcpErrorReporting.Reporter

  alias GoogleApi.CloudErrorReporting.V1beta1.Model.ReportedErrorEvent
  alias GoogleApi.CloudErrorReporting.V1beta1.Model.ServiceContext

  # @goth FakeGoth
  # @project_id "fake-project-id"

  describe "error_event" do
    test "basic config" do
      reporter = %Reporter{}

      assert Reporter.error_event("foo error", reporter) == %ReportedErrorEvent{
        message: "foo error",
        serviceContext: nil,
        context: nil
      }
    end

    test "with service" do
      reporter = %Reporter{service: "foo"}

      assert Reporter.error_event("foo error", reporter) == %ReportedErrorEvent{
        message: "foo error",
        serviceContext: %ServiceContext{service: "foo"},
        context: nil
      }
    end

    test "with service_version" do
      reporter = %Reporter{service_version: "main"}

      assert Reporter.error_event("foo error", reporter) == %ReportedErrorEvent{
        message: "foo error",
        serviceContext: %ServiceContext{version: "main"},
        context: nil
      }
    end

    test "with service and service_version" do
      reporter = %Reporter{service: "foo", service_version: "main"}

      assert Reporter.error_event("foo error", reporter) == %ReportedErrorEvent{
        message: "foo error",
        serviceContext: %ServiceContext{service: "foo", version: "main"},
        context: nil
      }
    end
  end
end
