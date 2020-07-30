FROM erlang:22.3.4.4-alpine
ENV ELIXIR_VERSION="v1.10.4"
LABEL maintainer="Connor Rigby (connorr@hey.com)"

WORKDIR /tmp/elixir-build

RUN apk --no-cache --update upgrade && \
    apk add --no-cache --update --virtual .elixir-build \
      make && \
    apk add --no-cache --update \
      git && \
    git clone https://github.com/elixir-lang/elixir --depth 1 --branch $ELIXIR_VERSION && \
    cd elixir && \
    make && make install && \
    mix local.hex --force && \
    mix local.rebar --force && \
    cd $HOME && \
    rm -rf /tmp/elixir-build && \
    apk del --no-cache .elixir-build

RUN apk add npm

ONBUILD RUN mix do local.hex --force, local.rebar --force

WORKDIR /app
COPY . .

RUN mix deps.get
RUN npm install --prefix assets
RUN npm run deploy --prefix assets
RUN mix deps.compile
RUN mix compile
RUN mix phx.digest
RUN mix release