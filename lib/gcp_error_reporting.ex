defmodule GcpErrorReporting do
  @moduledoc """
  Documentation for `GcpErrorReporting`.
  """

  alias GcpErrorReporting.Reporter

  alias GoogleApi.CloudErrorReporting.V1beta1.Connection
  alias GoogleApi.CloudErrorReporting.V1beta1.Api.Projects

  def report_error(error, stacktrace, %Reporter{goth: goth, project_id: project_id} = reporter) do
    Projects.clouderrorreporting_projects_events_report(
      connection(goth),
      project_id,
      body: Reporter.error_event(error, stacktrace, reporter)
    )
  end

  defp connection(goth) do
    token = Goth.fetch!(goth)
    Connection.new(token.token)
  end
end
