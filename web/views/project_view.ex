defmodule Abutment.ProjectView do
  use Abutment.View
  alias Abutment.Router.Helpers

  def render("show.json", %{project: project}) do
    Dict.put(base_json_api(), :projects, project_one(project)) |> add_links([project])
  end

  def render("index.json", %{projects: projects, params: params}) do
    Dict.put(base_json_api(), :projects, Enum.map(projects, &project_one(&1)))
    |> Dict.update(:meta, %{}, fn(val) ->
      Dict.merge(val, page(projects, params))
    end) |> add_links(projects)
  end

  def page(projects, params) do
    meta = %{
      page: params["page"],
      page_size: params["page_size"]
    }

    if Enum.count(projects) == params["page_size"] do
      next_page = Abutment.Router.Helpers.project_path(:index, Dict.merge(params, %{"page" => params["page"] + 1}))
      meta = Dict.put(meta, :next_page, next_page)
    end

    if params["page"] > 0 do
      previous_page = Abutment.Router.Helpers.project_path(:index, Dict.merge(params, %{"page" => params["page"] - 1}))
      meta = Dict.put(meta, :previous_page, previous_page)
    end
    meta
  end

  def project_one(project) do
    Dict.merge(base_resource_json(), base_project_json(project))
  end

  defp base_project_json(project) do
    %{
      id: to_string(project.id),
      href: Abutment.Router.Helpers.project_path(:show, project.id),
      type: "project",
      name: project.name,
      created_at: project.created_at,
      updated_at: project.updated_at,
      links: links(project)
    }
  end

  defp add_links(hash, projects) do
    Dict.put(hash, :links, %{
      "project.creator" => %{
        "href" => "#{Helpers.user_path(:index)}/{project.owner.id}",
        "type" => "user"
      },
    }) |> Dict.put(:linked, %{
        "users" => [ collect_users(projects) |> Enum.map(&Abutment.UserView.user_one(&1))]
      })
  end

  defp links(project) do
    %{
      owner: to_string(project.owner_id)
    }
  end

  defp collect_users(projects) do
    users = Enum.map(projects, fn(project) ->
      project.owner.get
    end)
    |> List.flatten 
    |> Enum.uniq(fn(user) -> user.id end)
  end
end
