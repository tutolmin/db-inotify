#!/bin/bash
#
# This simple script daemonizes inotify which waits for a close_write event
# in the incoming directory. Then it moves the complete file into the DB queue dir.
# It is important that the files in progress are kept in the incoming dir
# and NOT touched by the extractor script until they appear in db queue dir.
#
. /neo4j/.cc_profile

# CLOSE_WRITE:CLOSE Akobian.gz /neo4j/incoming/
# CLOSE_WRITE:CLOSE lines-6-5e5a2207ecfa3.txt.gz /neo4j/incoming/
# CLOSE_WRITE:CLOSE games-6-mo2120tutolmin-5e387070f1a9a.txt.gz /neo4j/incoming/

# Operation is non-blocking since we want all events served as they occur
nohup inotifywait -q -m -e close_write --format '%e %f %w' $INCOMINGDIR | \
(
while read event file dir
do 
  # Log the event into system log
  logger -t move_incoming "Moving $dir/$file -> $DBQUEUEDIR/$file"

  # Move the file into respective dbqueue directory
  mv $dir/$file $DBQUEUEDIR
done
) &
