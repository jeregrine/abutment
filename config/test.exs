use Mix.Config

config :abutment, Abutment.Endpoint,
  http: [port: System.get_env("PORT") || 4001]
