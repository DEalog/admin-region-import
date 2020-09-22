# PostGIS importer

This project contains an import for Verwaltungsgebiete data.

The used data is obtained from [Verwaltungsgebiete 1:250 000 (Ebenen), Stand 01.01.](https://gdz.bkg.bund.de/index.php/default/digitale-geodaten/verwaltungsgebiete/verwaltungsgebiete-1-250-000-ebenen-stand-01-01-vg250-ebenen-01-01.html)

## Usage

> Note: This container is used to mainly convert and view the data.
> **DO NOT USE IN PRODUCTION**

- Build the Docker container

```bash
docker build -t dealog/postgis:latest .
```

- Start the Docker container

```bash
docker run\
  --name postgis_import\
  --rm\
  -d\
  -p 15432:5432\
  -e POSTGRES_DBNAME=postgis\
  -v ${PWD}/data:/app/data\
  dealog/postgis:latest
```

- Run the import script

```bash
docker exec postgis_import ./import_verwaltungsgebiete.sh
```

## License

MIT
