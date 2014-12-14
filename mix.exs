defmodule Abutment.Mixfile do
  use Mix.Project

  def project do
    [app: :abutment,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: ["lib", "web"],
     compilers: [:phoenix] ++ Mix.compilers,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {Abutment, []},
     applications: [:phoenix, :cowboy, :logger, :postgrex, :ecto, :crypto, :bcrypt]]
  end

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [
     {:plug, github: "elixir-lang/plug", ref: "7040c89cb4cf1f1c6afdee379e5982a07d77a6c3", override: true},
     {:phoenix, "~> 0.7.0"},
     {:cowboy, "~> 1.0"},
     {:postgrex, ">= 0.0.0"},
     {:ecto, "~> 0.2.5"},
     {:timex, "~> 0.13.2"},
     {:erlpass, github: "ferd/erlpass", tag: "1.0.1"}
    ]
  end
end
