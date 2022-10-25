#!/usr/bin/awk -v DEBUG=0 -f

BEGIN {
    # Uncomment for debug output
    # DEBUG=1
    debug_print("Start qemu-img help scrapping")
    print "file:", "qemu-img"
}

# Main Start

/qemu\-img version/{
    qemu_img_version=$3
    print "version:", qemu_img_version
    next
}

END {
    debug_print("End qemu-ing help scrapping")
}

function debug_print(msg) {
   if (DEBUG == 1) {
       printf  "[DEBUG]: %s\n", msg
   }
}
