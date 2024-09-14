#!/bin/bash

OBA_VERSION="$@"

# If GTFS_URL is not set or is empty, then use a default value:
RESOLVED_GTFS_URL=${GTFS_URL:-https://unitrans.ucdavis.edu/media/gtfs/Unitrans_GTFS.zip}

echo "OBA Bundle Builder Starting"
echo "GTFS_URL: $GTFS_URL"
echo "Resolved GTFS_URL: $RESOLVED_GTFS_URL"
echo "OBA Version: $OBA_VERSION"

wget -O /bundle/gtfs.zip ${RESOLVED_GTFS_URL}

# The JAR must be executed from within the same directory
# as the bundle, or else some necessary files are not generated.

cd /bundle \
    && bash /oba/bin/gtfs_cleanup.sh gtfs.zip \
    && java -Xss4m -Xmx3g \
        -jar /oba/libs/onebusaway-transit-data-federation-builder-${OBA_VERSION}-withAllDependencies.jar \
        ./gtfs.zip \
        .
