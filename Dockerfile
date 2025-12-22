FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
	make nasm binutils

WORKDIR /project
COPY . .
RUN make

CMD ["bin/out"]
