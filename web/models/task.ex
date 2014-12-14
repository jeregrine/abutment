defmodule Abutment.TaskModel do
  use Ecto.Model
  import Ecto.Query
  alias Abutment.Repo

  schema "tasks" do
    field :title, :string
    field :body, :string
    field :tags, {:array, :string}
    belongs_to :owner, Abutment.UserModel, foriegn_key: :owner_id
    belongs_to :creator, Abutment.UserModel, foriegn_key: :creator_id


    field :created_at, :datetime
    field :updated_at, :datetime
  end

  # Title is the only requirement for a task. 
  validate task,
    title: present()

  def create(title, body, tags, creator_id, owner_id) do
    task = %__MODULE__{
      title: title,
      body: body,
      tags: cleanup_tags(tags),
      creator_id: creator_id,
      owner_id: owner_id
    }

    case validate(task) do
      [] -> {:ok, Repo.insert(task)}
      errors -> {:errors, errors}
    end
  end

  def update(task, title, body, tags, owner_id) do
    if title do
      task = %{task | title: title}
    end

    if body do
      task = %{task | body: body}
    end

    if tags do
      task = %{task | tags: cleanup_tags(tags)}
    end

    if owner_id do
      task = %{task | owner_id: owner_id}
    end

    case validate(task) do
      [] -> 
        task = %{task | updated_at: Ecto.DateTime.utc} 
        Repo.update(task)
      errors ->
        {:error, errors}
    end
  end

  def cleanup_tags([]), do: []
  def cleanup_tags(arr) do
    Enum.map(arr, &String.strip(&1))
      |> Enum.filter(fn(item) -> 
          item != "" && String.valid?(item)
        end)
  end

  def list(%{"sort" => sort, "include" => _include, "filter" => filter}) do
    query = from t in __MODULE__, 
              select: t

    if Dict.size(filter) > 0 do
      query = from t in query,
        where: ^filter
    end

    if Dict.size(sort) > 0 do
      query = from t in query,
        order_by: ^sort
    else
      query = from t in query,
        order_by: [asc: t.created_at]
    end

    query
  end
end
