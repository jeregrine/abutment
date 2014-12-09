defmodule Abutment.Authenticate do
  @behaviour Plug
  import Plug.Conn

  def init(_opts) do
  end

  def call(conn, _opts) do
    case get_session(conn, :user_id) do
      nil -> Abutment.SessionController.auth_error_resp(conn)
      user_id -> case Repo.get(Abutment.UserModel, user_id) do
        nil -> Abutment.SessionController.auth_error_resp(conn)
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
end
