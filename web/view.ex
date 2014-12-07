defmodule Abutment.View do
  use Phoenix.View, root: "web/templates"

  # The quoted expression returned by this block is applied
  # to this module and all other views that use this module.
  using do
    quote do
      # Import common functionality
      import Abutment.Router.Helpers

      # Use Phoenix.HTML to import all HTML functions (forms, tags, etc)
      use Phoenix.HTML

      # Common aliases
      alias Phoenix.Controller.Flash
      def render("404.json", _dc) do
        %{
          errors: [%{
              status: 404,
              title: "Resource was not found"
            }]
      }
      end
      def render("errors.json", %{errors: errors}) do
        json_errors = Enum.map(errors, fn({key, val}) ->
          %{
            status: 400,
            code: "Validations Failed",
            title: "#{key} #{val}",
            path: key
          }
        end)

        %{errors: json_errors}
      end
    end
  end


  # Functions defined here are available to all other views/templates
  def base_json_api() do
    %{
      meta: %{},
      links: %{},
      linked: %{},
    }
  end

  def base_resource_json() do
    %{
      id: "",
      type: "",
      href: "",
      links: %{}
    }
  end

  def base_error() do
    %{
      errors: []
    }
  end

  def date_format(date) do
    Ecto.DateTime.to_erl(date)
    |> Timex.Date.from
    |> Timex.DateFormat.format!("{ISOz}")
  end
end

defimpl Poison.Encoder, for: Ecto.DateTime do
  def encode(date, options) do
    Ecto.DateTime.to_erl(date)
    |> Timex.Date.from
    |> Timex.DateFormat.format!("{ISOz}")
    |> Poison.Encoder.BitString.encode(options)
  end
end
