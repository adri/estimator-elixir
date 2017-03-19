defmodule Estimator.Web.PageView do
  use Estimator.Web, :view

  def partial(template, assigns \\ %{}) do
    render(Estimator.Web.PartialView, template)
  end
end
