defmodule Abutment.SessionController do
  use Phoenix.Controller

  alias Abutment.UserModel
  alias Abutment.Router

  plug :action

  # GET /session
  def index(_conn, _params) do
  end

  # POST /users
  def create(conn, json=%{"format" => "json"}) do
    password = Dict.get(json, "password", nil)
    email = Dict.get(json, "email", nil)

    # Find User
    case UserModel.fetch(email) do
     nil -> put_status(conn, 400) |> render "errors.json"
     user -> case UserModel.password_check(password) do # Check Password
       true ->  put_resp_header(conn, "Location", Router.Helpers.session_path(:index))
                |> put_status(201)
                |> render "show.json", user: user
       false -> put_status(conn, 400) |> render "errors.json"
     end
    end
  end

  # DELETE /tasks/:id
  def destroy(_conn, %{"id": _id}) do
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


    Plug.Conn.send_resp(conn, conn.status || 200, "application/json", encoder.encode!(%{errors: json_errors}))
  end
end
