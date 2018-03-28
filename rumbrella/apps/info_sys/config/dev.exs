use Mix.Config

config :info_sys, InfoSys.Application,
  debug_errors: true,
  code_reloader: true

import_config "dev.secret.exs"
