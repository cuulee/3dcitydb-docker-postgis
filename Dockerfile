# 3DCityDB Dockerfile #########################################################
#   Official website    https://www.3dcitydb.net
#   GitHub              https://github.com/3dcitydb
###############################################################################
# Base image
FROM postgres:10.1
# Maintainer ##################################################################
#   Bruno Willenborg
#   Chair of Geoinformatics
#   Department of Civil, Geo and Environmental Engineering
#   Technical University of Munich (TUM)
#   <b.willenborg@tum.de>
MAINTAINER Bruno Willenborg, Chair of Geoinformatics, Technical University of Munich (TUM) <b.willenborg@tum.de>

# Setup PostGIS ###############################################################
# based on mdillon/postgis
ENV POSTGIS_MAJOR 2.4
ENV POSTGIS_VERSION 2.4.2+dfsg-1.pgdg90+1

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
    postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts=$POSTGIS_VERSION \
    postgis=$POSTGIS_VERSION

# Setup 3DCityDB ##############################################################
#   set default 3dcitydb version. Use "--build-arg" switch of "docker build" to
#   build with another version of 3dcitydb
#     -tested versions: 3.3.1, 3.0.0
###############################################################################
ARG version=3.3.1
ENV CITYDBVERSION=${version}

RUN set -x \
  && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
  && mkdir -p 3dcitydb && wget "https://github.com/3dcitydb/3dcitydb/archive/v${CITYDBVERSION}.tar.gz" -O 3dcitydb.tar.gz \
  && tar -C 3dcitydb -xzvf 3dcitydb.tar.gz 3dcitydb-$CITYDBVERSION/PostgreSQL/SQLScripts --strip=3  && rm 3dcitydb.tar.gz \
  && apt-get purge -y --auto-remove ca-certificates wget

RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./3dcitydb.sh /docker-entrypoint-initdb.d/3dcitydb.sh
COPY ./CREATE_DB.sql /3dcitydb/CREATE_DB.sql