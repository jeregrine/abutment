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
  validate task do
    title: present()

end
