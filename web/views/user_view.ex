defmodule Abutment.UserView do
  use Abutment.View

  def render("show.json", %{user: user}) do
    Dict.put(base_json_api(), :users, [user_one(user)])
  end

  def render("index.json", %{users: users, params: params}) do
    Dict.put(base_json_api(), :users, Enum.map(users, &user_one(&1)))
      |> Dict.update(:meta, %{}, fn(val) ->
        Dict.merge(val, page(users, params))
      end)
  end

  def page(users, params) do
    meta = %{
        page: params["page"],
        page_size: params["page_size"]
    }

    if Enum.count(users) == params["page_size"] do
      next_page = Abutment.Router.Helpers.user_path(:index, Dict.merge(params, %{page: params["page"] + 1}))
      meta = Dict.put(meta, :next_page, next_page)
    end

    if params["page"] > 0 do
      previous_page = Abutment.Router.Helpers.user_path(:index, Dict.merge(params, %{page: params["page"] - 1}))
      meta = Dict.put(meta, :previous_page, previous_page)
    end
    meta
  end


  def user_one(user) do
    Dict.merge(base_resource_json(), base_user_json(user))
  end

  defp base_user_json(user) do
    %{
      id: user.id,
      href: Abutment.Router.Helpers.user_path(:show, user.id),
      type: "user",
      name: user.name,
      created_at: user.created_at,
      updated_at: user.updated_at
    }
  end
end
