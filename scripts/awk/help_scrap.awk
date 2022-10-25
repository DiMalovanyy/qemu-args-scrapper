#!/usr/bin/awk -v DEBUG=0 -f

BEGIN {
    # Uncomment for debug output
    DEBUG=1
    debug_print("Start help scrapping")
}

# Main Start

END {
    debug_print("End help scrapping")
}

function debug_print(msg) {
   if (DEBUG == 1) {
       printf  "[DEBUG]: %s\n", msg
   }
}
