FROM kartoza/postgis:12.1

RUN apt update\
      && apt upgrade -y\
      && apt auto-remove -y\
      && apt install -y postgis curl unzip
RUN mkdir /app
WORKDIR /app
COPY import_verwaltungsgebiete.sh /app
COPY export_csv_verwaltungsgebiete.sh /app
