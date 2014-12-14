defmodule Abutment.Authenticate do
  @behaviour Plug
  import Plug.Conn

  def init(_opts) do
  end

  def call(conn, _opts) do
    case get_session(conn, :user_id) do
      nil -> auth_error_resp(conn)
      user_id -> 
        case Abutment.Repo.get(Abutment.UserModel, user_id) do
          nil -> auth_error_resp(conn)
          user -> assign(conn, :current_user, user)
        end
    end
  end

  def login(conn, nil), do: conn
  def login(conn, user) do
    put_session(conn, :user_id, user.id)
  end

  def logout(conn) do
    delete_session(conn, :user_id)
  end

  def auth_error_resp(conn) do
    json_errors = [%{
        status: 401,
        code: "Not Authenticated",
        title: "Please create a user session before continuing",
        links: %{
          session: Abutment.Router.Helpers.session_path(:index)
        }
    }]

    encoder = Application.get_env(:phoenix, :format_encoders)
              |> Keyword.get(:json, Poison)

    conn
      |> put_resp_content_type("application/json")
      |> send_resp(400, encoder.encode!(%{errors: json_errors}))
  end
end
