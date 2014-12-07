defmodule Abutment.TaskView do
  use Abutment.View

  def render("show.json", %{task: task}) do
    Dict.put(base_json_api(), :tasks, [task_one(task)])
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
      tags: task.tags

    }
  end
end
