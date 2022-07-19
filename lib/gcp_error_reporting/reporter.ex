defmodule GcpErrorReporting.Reporter do
  defstruct [:goth, :project_id, :service, :service_version, :sources]

  alias GoogleApi.CloudErrorReporting.V1beta1.Model.ErrorContext
  alias GoogleApi.CloudErrorReporting.V1beta1.Model.ReportedErrorEvent
  alias GoogleApi.CloudErrorReporting.V1beta1.Model.ServiceContext
  alias GoogleApi.CloudErrorReporting.V1beta1.Model.SourceLocation
  alias GoogleApi.CloudErrorReporting.V1beta1.Model.SourceReference

  def error_event(error, stacktrace, %__MODULE__{} = reporter) do
    format_error(error, stacktrace)
    |> error_event(reporter)
    |> with_source_location(stacktrace)
  end

  def error_event(message, %__MODULE__{} = reporter) do
    %ReportedErrorEvent{message: message}
    |> with_service_context(reporter)
    |> with_context(reporter)
  end

  def format_error(error, stacktrace) do
    [
      format_header(error, stacktrace),
      format_stacktrace(stacktrace),
      "--\n",
      format_banner(error, stacktrace),
      "\n"
    ]
    |> Enum.join()
  end

  defp format_header(%error{}, [{m, f, a, [file: file, line: line]} | _rest]) do
    error = Module.split(error) |> Enum.join(".")
    mfa = Exception.format_mfa(m, f, a)
    "#{error}: #{mfa} (#{file}:#{line})"
  end

  defp format_banner(error, stacktrace) do
    Exception.format_banner(:error, error, stacktrace)
  end

  defp format_stacktrace(stacktrace) do
    Exception.format_stacktrace(stacktrace)
    |> String.replace(~r/(^|\n)    /, "\n")
    |> String.replace(~r/(.*)\:(\d+)\: (.*)\n/, "\\1:\\2:in `\\3'\n")
  end

  defp with_service_context(event, %{service: nil, service_version: nil}), do: event
  defp with_service_context(event, %{service: service, service_version: version}), do: %{event | serviceContext: %ServiceContext{service: service, version: version}}

  defp with_context(event, %{sources: nil}), do: event
  defp with_context(event, %{sources: sources}) do
    references = Enum.map(sources, &%SourceReference{repository: Keyword.get(&1, :repository), revisionId: Keyword.get(&1, :revision)})
    %{event | context: %ErrorContext{sourceReferences: references}}
  end

  defp with_source_location(event, [{m, f, a, [file: file, line: line]} | _rest]) do
    mfa = Exception.format_mfa(m, f, a)
    %{event | context: %ErrorContext{reportLocation: %SourceLocation{filePath: to_string(file), functionName: mfa, lineNumber: line}}}
  end
end
