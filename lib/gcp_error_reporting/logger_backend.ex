defmodule GcpErrorReporting.LoggerBackend do
  # @related [test](/test/gcp_error_reporting/logger_backend_test.exs)

  def init(__MODULE__),
    do: init({__MODULE__, :gcp_error_reporting_logger})

  def init({__MODULE__, config_name}) do
    config = Application.get_env(:logger, config_name, [])
    {:ok, config}
  end

  # ignore any events that occurred on another node
  def handle_event({_level, pid, {Logger, _, _, _}}, config) when node(pid) != node(),
    do: {:ok, config}

  def handle_event({:error, _pid, {Logger, _, _timestamp, metadata}}, config) do
    case Keyword.get(metadata, :crash_reason) do
      nil ->
        {:ok, config}

      {error, stacktrace} ->
        Application.get_env(:gcp_error_reporting, :impl, GcpErrorReporting).report_error(
          error,
          stacktrace,
          config
        )

        {:ok, config}
    end

    {:ok, config}
  end

  # ignore any events that aren't errors
  def handle_event(_, config),
    do: {:ok, config}
end
