defmodule GcpErrorReporting do
  # @related [test](/test/gcp_error_reporting_test.exs)

  @moduledoc """
  Documentation for `GcpErrorReporting`.
  """

  defmodule Reporting do
    @callback report_error(error :: Exception.t() | :atom, list(), GcpErrorReporting.Reporter.t()) ::
                {:ok, GoogleApi.CloudErrorReporting.V1beta1.Model.ReportErrorEventResponse.t()}
                | {:ok, Tesla.Env.t()}
                | {:ok, list()}
                | {:error, any()}
  end

  alias GcpErrorReporting.Reporter

  alias GoogleApi.CloudErrorReporting.V1beta1.Connection
  alias GoogleApi.CloudErrorReporting.V1beta1.Api.Projects

  @behaviour GcpErrorReporting.Reporting

  @impl GcpErrorReporting.Reporting
  def report_error(error, stacktrace, %Reporter{goth: goth, project_id: project_id} = reporter) do
    Projects.clouderrorreporting_projects_events_report(
      connection(goth),
      project_id,
      body: Reporter.error_event(error, stacktrace, reporter)
    )
  end

  @spec register_logger_backend :: Supervisor.on_start_child()
  def register_logger_backend do
    {:ok, _pid} = Logger.add_backend(GcpErrorReporting.LoggerBackend)
  end

  # # #

  defp connection(goth) do
    token = Goth.fetch!(goth)
    Connection.new(token.token)
  end
end
