defmodule GcpErrorReporting.Reporter do
  defstruct [:goth, :project_id, :service, :service_version]

  alias GoogleApi.CloudErrorReporting.V1beta1.Model.ReportedErrorEvent
  alias GoogleApi.CloudErrorReporting.V1beta1.Model.ServiceContext

  def error_event(message, %__MODULE__{} = reporter) do
    %ReportedErrorEvent{message: message}
    |> with_service_context(reporter)
  end

  defp with_service_context(event, %{service: nil, service_version: nil}), do: event
  defp with_service_context(event, %{service: service, service_version: version}), do: %{event | serviceContext: %ServiceContext{service: service, version: version}}
end
