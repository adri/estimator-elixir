defmodule Estimator.GraphQL.Types do
  use Absinthe.Schema.Notation

  object :session do
    field :moderator, :string
    field :issues, list_of(:issue)
  end

  @desc "A issue, e.g. from Jira. Can have votes and an estimation."
  object :issue do
    field :key, non_null(:string)
    field :description, :string
    field :estimation, :string
    field :selected, non_null(:boolean)
    field :votes, list_of(:vote)
  end

  @desc "A vote on an issue by a user. Not an estimation yet."
  object :vote do
    field :vote, :string
    # field :user, :user
  end

  # @desc "A user"
  # object :user do
  #   field :id, :string
  #   field :name, :string
  #   field :avatarUrl, :string
  # end
end