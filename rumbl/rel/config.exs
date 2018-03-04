# Import all plugins from `rel/plugins`
# They can then be used by adding `plugin MyPlugin` to
# either an environment, or release definition, where
# `MyPlugin` is the name of the plugin module.
Path.join(["rel", "plugins", "*.exs"])
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    # default_environment: Mix.env()
    default_environment: :prod

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  # If you are running Phoenix, you should make sure that
  # server: true is set and the code reloader is disabled,
  # even in dev mode.
  # It is recommended that you build with MIX_ENV=prod and pass
  # the --env flag to Distillery explicitly if you want to use
  # dev mode.
  set dev_mode: true
  set include_erts: false
  set cookie: :"G`67>dsGkkZB)r,XhzeHvZUVdCOu;AD=)tKna^vyf?}YrsF?lyXLZj:9~$/Tq2B["
end

environment :prod do
  set include_erts: false
  set include_src: false
  #set cookie: :"Q%e:3n3!$KHqK5}RWMfyw9EunSGfP59oly~cs59nI3alna!?5g[J7&Ux8x/J4|$j"
  set cookie: :prod
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :rumbl do
  set version: current_version(:rumbl)
  set applications: [
    :runtime_tools
  ]
end

# use Mix.Releases.Config,
#   # This sets the default release built by `mix release`
#   default_release: :default,
#   # This sets the default environment used by `mix release`
#   default_environment: :default

# environment :default do
#   # Copy files into release instead of creating symlink for them
#   set dev_mode: false
#   # Do not include ERTS
#   set include_erts: false
#   # Do not include source code
#   set include_src: false
#   # Set the Erlang distribution cookie
#   set cookie: :"this_is_a_secret"
# end

# release :rumbl do
#   set version: current_version(:rumbl)
#   set applications: [
#     :runtime_tools
#   ]
# end