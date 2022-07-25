defmodule GcpErrorReportingTest do
  use ExUnit.Case, async: false

  describe "register_logger_backend" do
    test "registers a logger backend that reports errors" do
      GcpErrorReporting.register_logger_backend()
      on_exit(fn -> Logger.remove_backend(GcpErrorReporting.LoggerBackend) end)

      all_backends =
        Supervisor.which_children(Logger.BackendSupervisor)
        |> Enum.map(fn {backend, _, _, _} -> backend end)
        |> Enum.sort()

      assert GcpErrorReporting.LoggerBackend in all_backends
    end
  end
end
