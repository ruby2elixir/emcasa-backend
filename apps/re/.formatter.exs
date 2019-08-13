[
  inputs: ["mix.exs", "lib/**/*.{ex,exs}", "priv/repo/migrations/*.exs"],
  locals_without_parens: [
    field: 2,
    field: 3,
    has_many: :*,
    belongs_to: 2,
    belongs_to: 3,
    embeds_one: 2,
    embeds_many: 2,
    many_to_many: 3,
    config: 2,
    enum: 2,
    has_one: 2,
    drop: 1,
    remove: 1,
    create: 1,
    add: 2,
    add: 3,
    rename: 3,
    modify: 2,
    modify: 3,
    drop_if_exists: 1
  ]
]
