defmodule Abutment.TaskModel do
  use Ecto.Model

  schema "tasks" do
    field :title, :string
    field :body, :string
    field :tags, {:array, :string}

    field :created_at, :datetime
    field :updated_at, :datetime
  end

  # Title is the only requirement for a task. 
  validate task,
    title: present()


  def cleanup_tags([]), do: []
  def cleanup_tags(arr) do
    Enum.map(arr, &String.strip(&1))
      |> Enum.filter(fn(item) -> 
          item != "" && String.valid?(item)
        end)
  end
end
