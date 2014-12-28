defmodule Abutment.Repo do
  use Ecto.Repo, adapter: Ecto.Adapters.Postgres, env: Mix.env

  @doc "Adapter configuration"
  def conf(env), do: parse_url url(env)

  defp url(:dev) do
    "ecto://localhost/abutment_repo_dev"
  end

  defp url(:test) do
    "ecto://localhost/abutment_repo_test?size=1&max_overflow=0"
  end

  defp url(:prod) do
    System.get_env("DATABASE_URL")
  end

  @doc "The priv directory to load migrations and metadata."
  def priv do
    app_dir(:abutment, "priv/repo")
  end
end
