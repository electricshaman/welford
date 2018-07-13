defmodule Welford.MixProject do
  use Mix.Project

  def project do
    [
      app: :welford,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Welford.Application, []}
    ]
  end

  defp deps do
    [
      {:uuid, "~> 1.1"}
    ]
  end
end
