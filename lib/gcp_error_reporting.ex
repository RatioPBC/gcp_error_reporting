defmodule GcpErrorReporting do
  @moduledoc """
  Documentation for `GcpErrorReporting`.
  """

  alias GcpErrorReporting.Reporter

  alias GoogleApi.CloudErrorReporting.V1beta1.Connection
  alias GoogleApi.CloudErrorReporting.V1beta1.Api.Projects
  alias GoogleApi.CloudErrorReporting.V1beta1.Model.ErrorContext
  alias GoogleApi.CloudErrorReporting.V1beta1.Model.ReportedErrorEvent
  alias GoogleApi.CloudErrorReporting.V1beta1.Model.ServiceContext
  alias GoogleApi.CloudErrorReporting.V1beta1.Model.SourceLocation
  alias GoogleApi.CloudErrorReporting.V1beta1.Model.SourceReference

  def report_error(message, %Reporter{goth: goth, project_id: project_id} = reporter) do
    Projects.clouderrorreporting_projects_events_report(
      connection(goth),
      project_id,
      body: Reporter.error_event(message, reporter)
    )
  end

  defp connection(goth) do
    token = Goth.fetch!(goth)
    Connection.new(token.token)
  end
end
