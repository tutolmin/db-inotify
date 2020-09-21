#!/bin/bash
#
# This simple script daemonizes inotify which waits for a moved_to event
# in the db queue directory and fires the extractor script.
# Extractor script is smart enough to get the operations mode from filename
# This is non-blocking script as we want to process all files
#
. /neo4j/.cc_profile

# MOVED_TO Akobian.pgn.gz /neo4j/dbqueued/
# MOVED_TO games-6-mo2019tutolmin-5e5a2207ecfa3.txt.gz /neo4j/dbqueued/
# MOVED_TO lines-6-5e5a2207ecfa3.txt.gz /neo4j/dbqueued/

# Blocking approach. We do NOT want to handle other files while current file is being extracted
while inotifywait -qq -e moved_to $DBQUEUEDIR
do
  # Log the event into system log
  logger -t dbmerge_queued "Event in $DBQUEUEDIR"

  # Fires an extractor script
  $APPDIR/extractor.sh
done &
