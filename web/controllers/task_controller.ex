defmodule Abutment.TaskController do
  use Phoenix.Controller

  plug :action

  # GET /tasks
  def index(conn, _params) do
    render conn, "index.html"
  end

  # GET /tasks/:id
  def show(conn, %{"id": _id}) do
    render conn, "index.html"
  end

  # POST /tasks
  def create(conn, _params) do
    render conn, "index.html"
  end

  # PUT/PATCH /tasks/:id
  def update(conn, %{"id": _id}) do
    render conn, "index.html"
  end

  # DELETE /tasks/:id
  def destroy(conn, %{"id": _id}) do
    render conn, "index.html"
  end
end
