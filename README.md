# GCP Error Reporting

Report Elixir errors to [Google Error Reporting](https://cloud.google.com/error-reporting).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `gcp_error_reporting` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:gcp_error_reporting, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/gcp_error_reporting>.

## Configure Goth

`GcpErrorReporting` uses [`goth`](https://hex.pm/packages/goth) to authenticate with Google.
Follow its installation instructions to configure it, and define an app-specific Goth module to use with `GcpErrorReporting`.

## Define a `Reporter`

Example:

```elixir
version = System.fetch_env!("CI_COMMIT")

%GcpErrorReporting.Reporter{
  goth: MyApp.Goth,
  project_id: "gcp_project_name",
  service: "app_name",
  service_version: version,
  sources: [
    [repository: "https://www.github.com/org/project", revision: version]
  ]
}
```

## Catch errors and report them

TBD. something like:

```elixir
# in app outer loop:
begin do
  app_outer_loop
rescue e
  GcpErrorReporting.report_error(e, __STACKTRACE__, app_reporter)
end
```
