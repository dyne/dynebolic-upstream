#!/bin/sh

if [ -z $1 ]; then
 echo "you need arguments"
 exit 1
fi

FILE="dynebolic-${1}.sgml"
touch $FILE
echo "<section>" >> $FILE
echo "<title>${1}</title>" >> $FILE
echo "<para>to be written</para>" >> $FILE
echo "</section>" >> $FILE

echo "ok, $FILE created"

exit 0
