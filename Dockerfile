FROM elixir:1.7.4
ARG BUILD_DATE
ARG VCS_REF
LABEL maintainer="EmCasa <dev@emcasa.com>" \
      org.opencontainers.image.title="Backend service for EmCasa." \
      org.opencontainers.image.description="Backend service for EmCasa." \
      org.opencontainers.image.authors="EmCasa <dev@emcasa.com>" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://github.com/emcasa/backend" \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.created=$BUILD_DATE

# elixir install deps
RUN mix local.hex --force \
    && mix local.rebar --force

# app set workdir
WORKDIR /opt/emcasa/backend

# app install deps
COPY mix.exs mix.exs
COPY mix.lock mix.lock
# NOTE (jpd): there must be a better way to do this
COPY apps/re_integrations/mix.exs apps/re_integrations/mix.exs
COPY apps/re_web/mix.exs apps/re_web/mix.exs
COPY apps/re/mix.exs apps/re/mix.exs
RUN mix deps.get \
    && mix deps.compile

# app copy code
COPY . /opt/emcasa/backend
RUN mix compile
