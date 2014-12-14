defmodule Abutment.JSONAPIResponse do
  @behaviour Plug
  import Plug.Conn

  def init(_opts) do
  end

  def call(conn, _opts) do
    register_before_send(conn, fn(conn) ->
      if !conn.assigns[:override_json_api] do
        put_resp_content_type(conn, "application/vnd.api+json")
      end
    end)
  end
end
