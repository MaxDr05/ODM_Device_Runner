FROM debian:stable-slim

WORKDIR /app

RUN apt-get update && apt-get install -y android-tools-adb \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh .

RUN chmod +x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]