use Mix.Config

config :info_sys, :wolfram,
  app_id: "1234",
  # Overriding implementation for testing from evironment is a bad approach...
  # Thids means the code was not designed following Single Responsability Principle.
  http_client: InfoSys.Test.HTTPClient
