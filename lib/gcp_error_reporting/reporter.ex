defmodule GcpErrorReporting.Reporter do
  defstruct [:goth, :project_id, :service, :service_version]

  alias GoogleApi.CloudErrorReporting.V1beta1.Model.ReportedErrorEvent
  alias GoogleApi.CloudErrorReporting.V1beta1.Model.ServiceContext

  def error_event(message, %__MODULE__{} = reporter) do
    %ReportedErrorEvent{message: message}
    |> with_service(reporter.service)
    |> with_service_version(reporter.service_version)
  end

  defp with_service(event, nil), do: event
  defp with_service(event, service), do: %{event | serviceContext: %ServiceContext{service: service}}

  defp with_service_version(event, nil), do: event
  defp with_service_version(%{serviceContext: nil} = event, version), do: %{event | serviceContext: %ServiceContext{version: version}}
  defp with_service_version(%{serviceContext: context} = event, version), do: %{event | serviceContext: %{context | version: version}}
end
