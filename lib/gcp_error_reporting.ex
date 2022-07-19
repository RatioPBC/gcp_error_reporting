defmodule GcpErrorReporting do
  @moduledoc """
  Documentation for `GcpErrorReporting`.
  """

  alias GoogleApi.CloudErrorReporting.V1beta1.Connection
  alias GoogleApi.CloudErrorReporting.V1beta1.Api.Projects
  alias GoogleApi.CloudErrorReporting.V1beta1.Model.ReportedErrorEvent

  def report_error do
    Projects.clouderrorreporting_projects_events_report(
      connection(),
      projects_id(),
      body: error_body()
    )
  end

  defp error_body do
    %ReportedErrorEvent{
      message: message(),
      # serviceContext: service_context()
    }
  end

  defp message do
    """
    prog.rb:2:in `a'
    prog.rb:6:in `b'
    prog.rb:10
    """
  end

  defp connection do
    {:ok, token} = Goth.Token.for_scope("https://www.googleapis.com/auth/cloud-platform")
    Connection.new(token.token)
  end

  defp projects_id do
    System.fetch_env!("GCP_PROJECT")
  end
end
