defmodule Abutment.UserView do
  use Abutment.View
  import Integer, only: [to_string: 2]

  def render("show.json", %{user: user}) do
    Dict.put(base_json_api(), :users, user_one(user))
  end

  def user_one(user) do
    Dict.merge(base_resource_json(), base_user_json(user))
  end

  def base_user_json(user) do
    %{
      id: to_string(user.id),
      href: Abutment.Router.Helpers.user_path(:show, user.id),
      type: "user",
      name: user.name,
      created_at: user.created_at,
      updated_at: user.updated_at
    }
  end
end
