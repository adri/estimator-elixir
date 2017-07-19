defmodule Estimator.GraphQL.Schema do
  use Absinthe.Schema
  import_types Estimator.GraphQL.Types

  query do
    @desc "The current session the board."
    field :session, :session do
      resolve &Estimator.GraphQL.SessionResolver.current/2
    end
  end

  # mutation do
  #   @desc "Creates a series with the given title."
  #   field :create_series, :series do
  #     arg :title, non_null(:string)

  #     resolve &Estimator.GraphQL.SeriesResolver.create/2
  #   end

  #   @desc "Creates an episode for a given series."
  #   field :create_episode, :episode do
  #     @desc "The ID of the series this episode belongs to."
  #     arg :id, non_null(:integer)
  #     arg :title, non_null(:string)

  #     resolve &Estimator.GraphQL.EpisodeResolver.create/2
  #   end
  # end
end