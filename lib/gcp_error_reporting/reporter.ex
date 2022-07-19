defmodule GcpErrorReporting.Reporter do
  defstruct [:goth, :project_id, :service, :service_version, :sources]

  alias GoogleApi.CloudErrorReporting.V1beta1.Model.ErrorContext
  alias GoogleApi.CloudErrorReporting.V1beta1.Model.ReportedErrorEvent
  alias GoogleApi.CloudErrorReporting.V1beta1.Model.ServiceContext
  alias GoogleApi.CloudErrorReporting.V1beta1.Model.SourceReference

  def error_event(message, %__MODULE__{} = reporter) do
    %ReportedErrorEvent{message: message}
    |> with_service_context(reporter)
    |> with_context(reporter)
  end

  defp with_service_context(event, %{service: nil, service_version: nil}), do: event
  defp with_service_context(event, %{service: service, service_version: version}), do: %{event | serviceContext: %ServiceContext{service: service, version: version}}

  defp with_context(event, %{sources: nil}), do: event
  defp with_context(event, %{sources: sources}) do
    references = Enum.map(sources, &%SourceReference{repository: Keyword.get(&1, :repository), revisionId: Keyword.get(&1, :revision)})
    %{event | context: %ErrorContext{sourceReferences: references}}
  end
end
