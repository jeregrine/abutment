defmodule Abutment.TaskView do
  use Abutment.View

  def render("show.json", %{task: task}) do
    Dict.put(base_json_api(), :tasks, [task_one(task)])
  end

  def render("index.json", %{tasks: tasks, params: params}) do
    Dict.put(base_json_api(), :tasks, Enum.map(tasks, &task_one(&1)))
      |> Dict.update(:meta, %{}, fn(val) ->
        Dict.merge(val, page(tasks, params))
      end)
  end

  def page(tasks, params) do
    meta = %{
        page: params["page"],
        page_size: params["page_size"]
    }

    if Enum.count(tasks) == params["page_size"] do
      next_page = Abutment.Router.Helpers.task_path(:index, Dict.merge(params, %{"page" => params["page"] + 1}))
      meta = Dict.put(meta, :next_page, next_page)
    end

    if params["page"] > 0 do
      previous_page = Abutment.Router.Helpers.task_path(:index, Dict.merge(params, %{"page" => params["page"] - 1}))
      meta = Dict.put(meta, :previous_page, previous_page)
    end
    meta
  end


  def task_one(task) do
    Dict.merge(base_resource_json(), base_task_json(task))
  end

  defp base_task_json(task) do
    %{
      id: task.id,
      href: Abutment.Router.Helpers.task_path(:show, task.id),
      type: "task",
      title: task.title,
      body: task.body,
      tags: task.tags,
      created_at: task.created_at,
      updated_at: task.updated_at
    }
  end

end
