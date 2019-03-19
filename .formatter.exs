[
  inputs: ["mix.exs", "apps/**/mix.exs", "apps/**/{lib,test}/**/*.{ex,exs}"],
  subdirectories: ["apps/**"],
  locals_without_parens: [
    config: 1,
    config: 2,
    add: 2,
    add: 3,
    remove: 1
  ]
]
