defmodule GcpErrorReporting.LoggerBackendTest do
  # @related [subject](/lib/gcp_error_reporting/logger_backend.ex)

  require Logger

  use ExUnit.Case, async: false

  import ExUnit.CaptureLog
  import Mox

  setup :set_mox_from_context
  setup :verify_on_exit!

  describe "LoggerBackend" do
    setup do
      GcpErrorReporting.register_logger_backend()
      on_exit(fn -> Logger.remove_backend(GcpErrorReporting.LoggerBackend) end)
    end

    test "when something is logged but not at the :error level, nothing is reported to GCP" do
      expect(MockGcpErrorReporting, :report_error, 0, fn _, _, _ -> nil end)

      capture_log(fn ->
        Logger.info("a string")
      end)
    end

    test "when something is logged at the :error level, but it is not an Error, nothing is reported to GCP" do
      expect(MockGcpErrorReporting, :report_error, 0, fn _, _, _ -> nil end)

      capture_log(fn ->
        Logger.error("a string, not an exception")
      end)
    end

    test "when an Error is logged at the :error level, it is reported to GCP" do
      expect(MockGcpErrorReporting, :report_error, 1, fn _, _, _ -> nil end)

      capture_log(fn ->
        Logger.error("message", crash_reason: {"error", "stacktrace"})
      end)
    end
  end
end
