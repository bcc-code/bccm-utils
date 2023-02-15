run:
	go run .

docker:
	GOOS=linux GOARCH=amd64 go build -o bq-importer-linux-amd64 .
	sudo docker buildx build --platform linux/amd64 . -t europe-west4-docker.pkg.dev/bccm-k8s-main/bq-importer/bq-importer:latest
	docker push europe-west4-docker.pkg.dev/bccm-k8s-main/bq-importer/bq-importer:latest

