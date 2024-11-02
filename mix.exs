defmodule AvlTree.MixProject do
  use Mix.Project

  def project do
    [
      app: :avl_tree,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev], runtime: false}
    ]
  end
end
