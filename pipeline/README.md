# Docker and PostgreSQL Workshop

## Start the services

In Codespaces, configure the repository to use `pipeline/.devcontainer/devcontainer.json` as its devcontainer configuration. The devcontainer starts PostgreSQL, pgAdmin, and Jupyter whenever the Codespace starts or resumes. Rebuild the Codespace container once after changing the devcontainer configuration.

When `pipeline/` is open in VS Code, run this from the integrated terminal to start the services manually:

```bash
bash .devcontainer/start-workshop.sh
```

PostgreSQL uses port `5432`, pgAdmin uses port `8085`, and Jupyter uses port `8888`. In Codespaces, find their links in the VS Code **Ports** tab. In local VS Code, open pgAdmin at <http://localhost:8085> and Jupyter at <http://localhost:8888>. Jupyter may require its token; retrieve it from this directory with:

```bash
uv run jupyter server list
```

## pgAdmin connection

Log in with `admin@admin.com` / `root`. Register a server with:

- Name: `Local Docker`
- Host: `pgdatabase`
- Port: `5432`
- Maintenance database: `ny_taxi`
- Username/password: `root` / `root`

The Compose configuration preserves the tutorial host name and includes the Codespaces network and proxy settings.

## Ingest data

Run the January ingestion from the `pipeline/` directory. Change `--target-table` to choose the table name:

```bash
uv run python ingest_data.py \
	--pg-user=root --pg-pass=root --pg-host=localhost --pg-port=5432 \
	--pg-db=ny_taxi --target-table=yellow_taxi_trips \
	--year=2021 --month=1 --chunksize=100000
```

Build the ingestion image from this directory:

```bash
docker build -f dockerfile -t taxi_ingest:v001 .
```

In this Codespace, run the container with host networking so it can resolve the dataset host and reach the published PostgreSQL port:

```bash
docker run --rm --network=host taxi_ingest:v001 \
	--pg-user=root --pg-pass=root --pg-host=localhost --pg-port=5432 \
	--pg-db=ny_taxi --target-table=yellow_taxi_trips_2021_2 \
	--year=2021 --month=2 --chunksize=100000
```

## Keep database data

PostgreSQL and pgAdmin use the named volumes `ny_taxi_postgres_data` and `pgadmin_data`. They survive stopping/resuming this Codespace and restarting the Compose services. To stop services without deleting their data, run `docker compose --project-name docker-workshop down` from this directory, then start again with `bash .devcontainer/start-workshop.sh`.

Do not run `docker compose down -v` or remove those volumes unless you intend to delete the database and pgAdmin settings. Named volumes are not backups and do not guarantee data survives deleting the Codespace.
