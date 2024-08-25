FROM ghcr.io/gleam-lang/gleam:v1.4.1-erlang-alpine AS build

# Get build dependencies
RUN apk update && apk add build-base

# Copy source and build an Erlang shipment
WORKDIR /build
COPY . .
RUN gleam export erlang-shipment \
  && mv build/erlang-shipment /app \
  && rm -r /build

# Bundle build in minimal image
FROM erlang:27.0.1.0-alpine AS final
COPY --from=build /app /app

# Set up for running
EXPOSE 3000
WORKDIR /app
ENTRYPOINT ["./entrypoint.sh"]
CMD ["run"]
