FROM debian:bookworm-slim AS build

RUN apt-get update && apt-get install -y make nasm binutils

WORKDIR /project
COPY . .
RUN make


FROM debian:bookworm-slim

WORKDIR /project
COPY --from=build /project/bin/out tictactoe

CMD ["./tictactoe"]
