defmodule Abutment.Endpoint do
  use Phoenix.Endpoint, otp_app: :abutment

  plug Plug.Static,
  at: "/", from: :abutment

  plug Plug.Logger

  # Code reloading will only work if the :code_reloader key of
  # the :phoenix application is set to true in your config file.
  plug Phoenix.CodeReloader

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_abutment_session_#{Mix.env}",
    signing_salt: Application.get_env(:abutment, :signing_salt, "BseWFusf"),
    encryption_salt: Application.get_env(:abutment, :encryption_salt, "pdCvsICN")

  plug :router, Abutment.Router
end
