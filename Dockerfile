# Dockerfile for Production
FROM elixir:1.16-alpine AS build

# install build dependencies
RUN apk add --no-cache build-base git npm

# set environment
ENV MIX_ENV=prod

# create app directory
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# install dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get --only prod
RUN mix deps.compile

# build assets
COPY assets assets
RUN cd assets && npm install && npm run build

# build release
COPY lib lib
COPY priv priv
RUN mix compile
RUN mix release

# ---- Run stage ----
FROM elixir:1.16-alpine AS app
RUN apk add --no-cache openssl ncurses-libs

WORKDIR /app
COPY --from=build /app/_build/prod/rel/realtime_chat ./realtime_chat

ENV HOME=/app
ENV MIX_ENV=prod
ENV SHELL=/bin/sh
CMD ["./realtime_chat/bin/realtime_chat", "start"]
