defmodule GS.MixProject do
  use Mix.Project

  def project do
    [
      app: :genstages,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {GS.Application, []}
    ]
  end

  defp deps do
    [
      {:gen_stage, "~> 0.12"}
    ]
  end
end
