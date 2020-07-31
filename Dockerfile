FROM erlang:22.3.4.4-alpine as build
ENV ELIXIR_VERSION="v1.10.4"

# # install elixir
RUN wget https://repo.hex.pm/builds/elixir/$ELIXIR_VERSION.zip && \
    mkdir -p /usr/local/elixir && \
    unzip -d /usr/local/elixir $ELIXIR_VERSION.zip
ENV PATH=/usr/local/elixir/bin:$PATH

RUN apk add bash npm make alpine-sdk ffmpeg-dev libjpeg-turbo-dev

RUN mix do local.hex --force, local.rebar --force

from build AS compile

ENV MIX_ENV=prod
WORKDIR /app

COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile

# build assets
COPY assets/package.json assets/package-lock.json ./assets/
RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error

COPY priv priv
COPY assets assets
RUN npm run --prefix ./assets deploy
RUN mix phx.digest

# compile and build release
COPY lib lib
RUN mix do compile, release

# prepare release image
FROM alpine:3.9 AS app
RUN apk add --no-cache openssl ncurses-libs

ENV MIX_ENV=prod
WORKDIR /app

RUN chown nobody:nobody /app

USER nobody:nobody

COPY --from=compile --chown=nobody:nobody /app/_build/prod/rel/noven ./

ENV HOME=/app

CMD ["bin/noven", "start"]
