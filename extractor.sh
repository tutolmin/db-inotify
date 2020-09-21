#!/bin/bash
#
# The script finds first file in the db queue dir
# Then it parses the name of the file.
# If it starts with 'lines-' the script runs :Line merge
# Otherwise it goes for regular :Games merge
#
. /neo4j/.cc_profile

# Lockfile
LOCKFILE="$LOCK"

# Create lockfile if not exists, otherwise exit
if [[ ! -e $LOCKFILE ]]; then
#  logger -t extractor "Creating $LOCKFILE < $$"
  logger -t extractor "Creating $LOCKFILE"
  echo $$ > $LOCKFILE
else
  logger -t extractor "$LOCKFILE present!"
  exit
fi

# Iterate through all the files in the dbqueue dir
while : ; do

  # Find the next file in PGN dbqueue dir
  FILE=`find $DBQUEUEDIR -type f -name \*.gz -print0 -quit`

  # Exit the loop if no more files found
  if [[ ! -f $FILE ]]; then
    break;
  fi

  # Fetch the extractor mode (games|lines) from filename
  filename=$(basename -- "$FILE")
  MODE=$(echo $filename | cut -f 1 -d'-')

  # :Line only db merge
  if [[ "$MODE" == "lines" ]]; then

    logger -t extractor "DB merging :Lines from $FILE"

    # Extract games/lines in to workdir
    zcat $FILE | $BINDIR/extractor -A $APPDIR/args.lines -l $APPDIR/log.lines -o $APPDIR/err.lines

  else 

    logger -t extractor "DB merging :Games from $FILE"

    # Extract games/lines in to workdir
    zcat $FILE | $BINDIR/extractor -A $APPDIR/args.games -l $APPDIR/log.games -o $APPDIR/err.games

  fi

  # Delete processed file
  unlink $FILE

done

logger -t extractor "Deleting $LOCKFILE"

# remove lock file
unlink $LOCKFILE
