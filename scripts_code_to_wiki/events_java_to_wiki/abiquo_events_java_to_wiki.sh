#! /bin/sh
# Convert EventType.java to Confluence Wiki Format
# Note that it is best to cut the java code from the beginning and end of the file as that is not included in the scope of this script
# Read EventType.java file $1 and write to wiki output $2
# Mark comments starting with // as header records
# Strip whitespace in the file
# Set the record separator as "), "
# Print the first field of lines with one field beginning with // as h5. in wiki format after stripping non-numerics, then print header table row with first letter only in caps
# If header record, print header 
# Note that the last record is not processed properly because of EOF or something
# Print normal error message lines separated by | for wiki format
## replace {} with ""
## replace [] with ()
# Leaves other // comments in file - check for these
cat $1 | gawk '
{
   if ($0 ~ /^ *\/\//)  
      { print "h5. " $0 "\")," ; } 
   else 
      { print $0 }
}' | sed ':a;N;$!ba;s/^[ \t]*/ /;s/[ \t]*$/ /;' | sed 's/^ *//;s/ *$//;s/ \{1,\}/ /g' | sed ':a;N;$!ba;s/\n//g'  \
| gawk 'BEGIN { FS="\\, *\"|\\(|\\, *"; RS="\"\)\\,|\)\\, +"; } 
{ 

   if (NF > 1)
   {
      j[NR] = $1;
      event_num[NR] = $2;
      event_lab[NR] = $3;
      event_msg[NR] = $4;
      em = event_msg[NR];
      gsub(/(\")/,"",em);
      event_msg[NR] = em;
      outs [NR] = "| " event_num [NR] " | " event_lab [NR] " | " event_msg[NR] " |" ;
   }
 
   if (NF == 1)
   {
      if ($0 ~ /(^h5\.) *\/\//)
      { 
         header_txt = $0;
         gsub(/(^h5\.) *\/\//,"",header_txt);
         header_len = length(header_txt);
         header_start = substr(header_txt,1,2);
         header_end = substr(header_txt,3);
         header_first = toupper(header_start);   
         header_rem = tolower(header_end);
         header_out = (header_first header_rem);
         outs [NR] = "\nh5. " header_out "\n|| Event No. || Internal Message ID {color:#efefef}__________________{color}|| Message {color:#efefef}____________________________________________________________{color} ||"; 
      }
   }      
}
      
END {for (s=1; s<=NR; s++) {print outs[s];}}' >$2 
