#! /bin/sh
# Convert java.properties to Confluence Wiki Format
# Based on http://shrubbery.mynetgear.net/c/display/W/Reading+Java-style+Properties+Files+with+Shell#ReadingJava-stylePropertiesFileswithShell-Method2reloaded-UseAWK
# Read properties file $1 and write to properties output $2
# Ignore lines beginning with ####
# Print lines beginning with ## as h5. in wiki format after stripping non-numerics
# Print lines beginning with # as h6. in wiki format after stripping non-numerics, then print header table row
# Print normal properties lines with fields separated by | for wiki format
## replace {} with ""
## replace \n with "- "
## replace \: with :
## replace [] with (),
# Leaving the two single quotes at the start and end of the {} is a good way to detect problems with lack of escapes in the properties files
# Input files: tracer.properties, tracer-premium.properties
# Output files: tp.txt, tpp.txt
cat $1 | gawk 'BEGIN { FS="="; } 
/^\#\#\#/ { next; }
/^\#\#/ { n = $1 ; gsub(/[^A-Za-z0-9_]/,"",n) ; print "h5. " n; next; } 
/^\#/ { n = $1; gsub(/[^A-Za-z0-9_]/," ",n) ; print "h6. " n ; print "|| Internal Message ID {color:#efefef}_________________________________________{color}|| Message {color:#efefef}___________________________________________________________________________{color} ||"; next; } 
!/^\#/ { if (NF >= 2) { n = $2 ; { for ( f=3 ; f <= NF ; f++ ) { n = n "=" $f;};}; gsub(/{/,"",n); gsub(/}/,"",n); gsub(/\[/,"(",n); gsub(/\]/,")",n); gsub(/(\\)(n)/,"- ",n); gsub(/(\\)(:)/,":",n); print "| " $1 " | " n " |"; } else { print; }}'  >$2
