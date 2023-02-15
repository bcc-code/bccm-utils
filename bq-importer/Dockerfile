FROM alpine
RUN mkdir /work
WORKDIR /work
COPY ./bq-importer-linux-amd64 /work/run
COPY ./schema.json /work/schema.json
CMD ["/work/run"]
