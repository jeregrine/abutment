use Mix.Config

config :abutment, Abutment.Endpoint,
  http: [port: System.get_env("PORT") || 4000],
  debug_errors: true,
  signing_salt: "BseWFusf",
  encryption_salt: "pdCvsICN"

# Enables code reloading for development
config :phoenix, :code_reloader, true
