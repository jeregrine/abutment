defmodule Abutment.SessionView do
  use Abutment.View

  def render("show.json", %{user: user}) do
    Dict.put(base_json_api(), :sessions, [session_one(user)])
  end

  def session_one(user) do
    Dict.merge(base_resource_json(), base_session_json(user))
  end

  defp base_session_json(user) do
    Dict.merge(Abutment.UserView.base_user_json(user), %{ email: user.email })
  end
end
