Mox.defmock(MockGcpErrorReporting, for: GcpErrorReporting.Reporting)
Application.put_env(:gcp_error_reporting, :impl, MockGcpErrorReporting)

ExUnit.configure(exclude: [integration: true])
ExUnit.start()
