use Mix.Config

config :phoenix, Abutment.Router,
  http: [port: System.get_env("PORT") || 4001]
