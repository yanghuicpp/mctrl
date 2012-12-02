#!/bin/sh 
#
# This script generates resource script header (typically 'resource.h')
# from a template file (e.g. 'resource.h.in') and replaces some tokens
# with (increasing) number sequences. It simplifies management of resource
# IDs in the project.
#
# Notes:
#  -- Menu items share ID sequence with string IDs so app. can have simple
#     code providing some help message for each menu item.
#  -- Some ID counters start at 100 to reserve some space for special values,
#     e.g. IDOK, IDCANCEL, xml manifest etc.
#


selfname="`basename $0`"


# Writes out usage info of this script:
function usage
{
    cat << EOF
The script '$selfname' generates windows resource script header from
a template file. It can manage windows resource script IDs in a project.

Usage: $selfname [OPTIONS] INFILE -o OUTFILE

Options:
    -h, --help         write down this brief help
    -f, --force        rewrite existing files without warning
    -v, --verbose      output what the script is doing

Supported tokens:
    @RESOURCE_ID@      for ICON, BITMAP, DIALOG and generally for all resources
                         which are not covered by other tokens
    @CONTROL_ID@       for controls in DIALOG resources
    @STRING_ID@        for strings in a STRINGTABLE resource
    @MENUITEM_ID@      for menu items in MENU resources
EOF
}

# Parse command line otpions
while test $# -ne 0; do
	case $1 in
		-h | --help )
			# Write down usage
			usage
			exit 0
			;;
	
	    -v | --verbose )
	        # Be verbose
	        set -x
	        ;;
	    
	    -f | --force )
	        force=yes
	        ;;
	
		-o )
			# Output file name shoud follow
			shift
			outfile=$1
			if [ -z "$outfile" ]; then
				usage
				exit 1
			fi
			;;
			
		-* )
			# Unsupported options
			usage
			exit 1
			;;
			
		* )
			# Should be input file name
			if [ -n "$infile" ]; then
				usage
				exit 1
			fi
			infile=$1
			;;
	esac
		
	shift
done


# Check that input and output file names are set
if [ -z "$infile" -o -z "$outfile" ]; then
	usage
	exit 1
fi


# ID counters for specific resource types. 
resource_id=100
control_id=100
string_id=0    # used also for menu items


# We will generate to temporatry file. Otherwise it could confuse Make.
# If user interrupts the script (e.g. with CTRL+C), the final output 
# file's timestamp will not be updated. 
tmpfile="$outfile.tmp"


if [ x$force = xyes ]; then
    rm -rf "$tmpfile"
    rm -rf "$outfile"
fi

if [ -a "$tmpfile" ] ; then
    echo "'$tmpfile' already exists. Giving up."
    exit 1
fi

# Trap exit to remove the temporary file.
trap "rm -f \"$tmpfile\"" EXIT


# Place a warning into the file that it is generated:
cat >> "$tmpfile" << EOF
/* This file is generated automatically from '$infile' by script '$selfname'.
 * Do not edit this file manually.
 */
 
EOF

# Copy the input file to output file line by line. If present, replace
# the @COUNTER@ with the counter's actual value and increment it.
while read -r; do
	line="$REPLY"
    case "$line" in
        *@RESOURCE_ID@* )
            echo "$line" | sed "s/@RESOURCE_ID@/$resource_id/" >> "$tmpfile"
            resource_id=$(($resource_id+1))
            ;;
            
        *@CONTROL_ID@* )
            echo "$line" | sed "s/@CONTROL_ID@/$control_id/" >> "$tmpfile"
            control_id=$(($control_id+1))
		    ;;
		    
        *@STRING_ID@* )
            echo "$line" | sed "s/@STRING_ID@/$string_id/" >> "$tmpfile"
            string_id=$(($string_id+1))
		    ;;
		     
		*@MENUITEM_ID@* )
            echo "$line" | sed "s/@MENUITEM_ID@/$string_id/" >> "$tmpfile"
            string_id=$(($string_id+1))
		    ;;

        * )
            echo "$line" >> "$tmpfile"
            ;;
    esac
done < "$infile"

# Make the generated file read-only, to prevent accidental editations:
chmod ugo=r "$tmpfile"

# Finally rename the temporary file to the requested output filename:
mv -f "$tmpfile" "$outfile"
