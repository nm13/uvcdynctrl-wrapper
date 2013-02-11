#
# a small wrapper for the uvcdynctrl utility from the libwebcam project,
# see
#       <thisfile> --help

echo2() {
    echo "$@" 1>&2;
}


#
# uvcdynctrl output example:
#
: <<EOC
$ uvcdynctrl -c
Listing available controls for device video0:
  Sharpness
  Gamma
  Hue
  Saturation
  Contrast
  Brightness
EOC


uvc=uvcdynctrl

getparams() {
  # start from the 2nd line, effectively listing only the parameter names
  # uvcdynctrl -c | tail --lines=+2
  $uvc -c | tail --lines=+2
}

case "$1" in
    '--help') echo2 \
"usage:
	`basename $0` [<param-abbrev-1> <value-1>  [<param-abbrev-2> <value-2>   [ ... ]]]

-- e.g. ''`basename $0` co 50 hue 10' to set Contract to 50 
   and Hue (''colorfulness'') to 10 
   ( via: 'uvcdynctrl -s Contrast 50; uvcdynctrl -s Hue 10' )

also prints the available parameters and their values ( use >/dev/null to suppress that ) )
"      ;;
    *)
    while [ "$#" -gt 0 ] ;
    do
        # echo "arg: $1" ; shift; 

        #
	# find parameter
        #

	abbrev="$1"
        value="$2"

	# param=`getparams | grep -i "$abbrev"`
	param=`getparams | grep -i "^\s*$abbrev"`

        # set it
        echo "# $uvc -s $param "$value""
	$uvc -s $param "$value"

        # next pair
	shift 2
    done;

    # now print the resulting parameter set:
    getparams | xargs -I{} sh -c "echo -n '{}: '; '$uvc' -g {}"

# the old imperfect way to do things: )
: <<Comment-Out
    for ctrl in \
      Sharpness \
      Gamma     \
      Hue       \
      Saturation \
      Contrast   \
      Brightness \
    ;
    do
      echo -n "$ctrl"': '
      uvcdynctrl -g "$ctrl"
    done
Comment-Out
       ;;
esac;

