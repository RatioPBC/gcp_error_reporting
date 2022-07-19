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

  def report_error(%Reporter{goth: goth, project_id: project_id}) do
    Projects.clouderrorreporting_projects_events_report(
      connection(goth),
      project_id,
      body: error_body()
    )
  end

  defp error_body do
    %ReportedErrorEvent{
      message: message(),
      serviceContext: service_context(),
      context: context()
    }
  end

  defp message do
    """
    Pat's super duper cool error

    path/to/prog.ex:2:in `My.Mod.a'
    path/to/prog.ex:6:in `My.Mod.b'
    path/to/prog.ex:10:in `My.Mod.c'
    --
    Pat's super duper cool error
    Multi-line error message line 1
    Multi-line error message line 2
    Multi-line error message line 3
    --
    Some extra context
    Cool that it gets sent
    """
  end

  defp connection(goth) do
    token = Goth.fetch!(goth)
    Connection.new(token.token)
  end

  defp service_context do
    %ServiceContext{
      service: "gcp-error-reporting",
      version: "pat-dev"
    }
  end

  defp context do
    %ErrorContext{
      reportLocation: report_location(),
      sourceReferences: source_references()
    }
  end

  defp report_location do
    %SourceLocation{
      filePath: "foo.ex",
      functionName: "My.Module.foo",
      lineNumber: 123
    }
  end

  defp source_references do
    [
      %SourceReference{
        repository: "https://www.github.com/tba",
        revisionId: "main"
      }
    ]
  end
end
