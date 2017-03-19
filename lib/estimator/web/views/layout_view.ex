defmodule Estimator.Web.LayoutView do
  use Estimator.Web, :view

  def partial(template, assigns \\ %{}) do
    render(Estimator.Web.PartialView, template, assigns)
  end
end
