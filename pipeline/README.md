# Docker and PostgreSQL Workshop

## Start the services

In Codespaces, the devcontainer starts PostgreSQL, pgAdmin, and Jupyter whenever the Codespace starts or resumes. Rebuild the Codespace container once after adding the devcontainer configuration to activate it.

To start them manually from the repository root:

```bash
bash .devcontainer/start-workshop.sh
```

Ports are forwarded privately: PostgreSQL `5432`, pgAdmin `8085`, and Jupyter `8888`. Find their links in the VS Code **Ports** tab. Jupyter may require its token; retrieve it with:

```bash
cd pipeline && uv run jupyter server list
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

Run the following commands from the `pipeline/` directory. Change `--target-table` to choose the table name:

```bash
uv run python ingest_data.py \
	--pg-user=root --pg-pass=root --pg-host=localhost --pg-port=5432 \
	--pg-db=ny_taxi --target-table=yellow_taxi_trips \
	--year=2021 --month=1 --chunksize=100000
```

Build the ingestion image:

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

PostgreSQL and pgAdmin use the named volumes `ny_taxi_postgres_data` and `pgadmin_data`. They survive stopping/resuming this Codespace and restarting the Compose services. To stop services without deleting their data, run `docker compose --project-directory .. -f compose.yaml down` from `pipeline/`, then start again with `bash .devcontainer/start-workshop.sh` from the repository root.

Do not run `docker compose down -v` or remove those volumes unless you intend to delete the database and pgAdmin settings. Named volumes are not backups and do not guarantee data survives deleting the Codespace.
