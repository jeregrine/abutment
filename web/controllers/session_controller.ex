defmodule Abutment.SessionController do
  use Phoenix.Controller

  alias Abutment.UserModel
  alias Abutment.Router
  alias Abutment.Authenticate

  plug Abutment.Authenticate when action in [:index, :destroy]
  plug :action

  # GET /sessions
  def index(conn, _params) do
    render conn, "show.json", user: conn.assigns[:current_user]
  end

  # POST /sessions
  def create(conn, json=%{"format" => "json"}) do
    session_json = Dict.get(json, "sessions", %{})
    password = Dict.get(session_json, "password", nil)
    email = Dict.get(session_json, "email", nil)

    # Find User
    case UserModel.fetch(email) do
     nil -> put_status(conn, 400) |> render "errors.json"
     user -> case UserModel.password_check(user, password) do # Check Password
       true ->  put_resp_header(conn, "Location", Router.Helpers.session_path(:index))
                |> Authenticate.login(user)
                |> put_status(201)
                |> render "show.json", user: user
       false -> put_status(conn, 400) |> render "errors.json"
     end
    end
  end

  # DELETE /sessions
  def destroy(conn, _params) do
    Authenticate.logout(conn)
      |> resp(204, "")
      |> send_resp
  end
end
