# shell-script-functions.sh
#
# shell script functions for Relax & Recover
#
#    Relax & Recover is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.

#    Relax & Recover is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with Relax & Recover; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
#

# source a file given in $1
function Source() {
	# skip empty
	if test -z "$1" ; then
		return
	fi
	[[ ! -d "$1" ]]
	StopIfError "$1 is a directory, cannot source"
	if test -s "$1" ; then
		local relname="${1##$SHARE_DIR/}"
		if test "$SIMULATE" && expr "$1" : "$SHARE_DIR" >&8; then
			# simulate sourcing the scripts in $SHARE_DIR
			LogPrint "Source $relname"
		else
			# step-by-step mode or brakepoint if needed
			[[ "$STEPBYSTEP" || ( "$BREAKPOINT" && "$relname" == @($BREAKPOINT) ) ]] && read -p "Press ENTER to include '$1' ..." 2>&1

			Log "Including ${1##$SHARE_DIR/}"
			test "$DEBUGSCRIPTS" && set -x
			. "$1"
			test "$DEBUGSCRIPTS" && set +x
			[[ "$BREAKPOINT" && "$relname" == @($BREAKPOINT) ]] && read -p "Press ENTER to continue ..." 2>&1
		fi
	else
		Debug "Skipping $1 (file not found or empty)"
	fi
}

# collect scripts given in $1 in the standard subdirectories and
# sort them by their script file name and
# source them
function SourceStage() {
	stage="$1"
	shift
	STARTSTAGE=$SECONDS
	Log "Running '$stage' stage"
	scripts=( 
		$(
		cd $SHARE_DIR/$stage ; 
		# We always source scripts in the same subdirectory structure. The {..,..,..} way of writing
		# it is just a shell shortcut that expands as intended.
		ls -d	{default,"$ARCH","$OS","$OS_MASTER_VENDOR","$OS_MASTER_VENDOR_ARCH","$OS_MASTER_VENDOR_VERSION","$OS_VENDOR","$OS_VENDOR_ARCH","$OS_VENDOR_VERSION"}/*.sh \
			"$BACKUP"/{default,"$ARCH","$OS","$OS_MASTER_VENDOR","$OS_MASTER_VENDOR_ARCH","$OS_MASTER_VENDOR_VERSION","$OS_VENDOR","$OS_VENDOR_ARCH","$OS_VENDOR_VERSION"}/*.sh \
			"$OUTPUT"/{default,"$ARCH","$OS","$OS_MASTER_VENDOR","$OS_MASTER_VENDOR_ARCH","$OS_MASTER_VENDOR_VERSION","$OS_VENDOR","$OS_VENDOR_ARCH","$OS_VENDOR_VERSION"}/*.sh \
			"$OUTPUT"/"$BACKUP"/{default,"$ARCH","$OS","$OS_MASTER_VENDOR","$OS_MASTER_VENDOR_ARCH","$OS_MASTER_VENDOR_VERSION","$OS_VENDOR","$OS_VENDOR_ARCH","$OS_VENDOR_VERSION"}/*.sh \
		| sed -e 's#/\([0-9][0-9]\)_#/!\1!_#g' | sort -t \! -k 2 | tr -d \! 
		)
		# This sed hack is neccessary to sort the scripts by their 2-digit number INSIDE indepentand of the
		# directory depth of the script. Basicall sed inserts a ! before and after the number which makes the
		# number always field nr. 2 when dividing lines into fields by !. The following tr removes the ! to
		# restore the original script name. But now the scripts are already in the correct order.
		)
	# if no script is found, then $scripts contains only .
	# remove the . in this case
	test "$scripts" = . && scripts=()
	
	if test "${#scripts[@]}" -gt 0 ; then
		for script in ${scripts[@]} ; do
			Source $SHARE_DIR/$stage/"$script" 
		done
		Log "Finished running '$stage' stage in $((SECONDS-STARTSTAGE)) seconds"
	else
		Log "Finished running empty '$stage' stage"
	fi
}


function cleanup_build_area_and_end_program() {
	# Cleanup build area
	LogPrint "Finished in $((SECONDS-STARTTIME)) seconds."
	if test "$KEEP_BUILD_DIR" ; then
		LogPrint "You should also rm -Rf $BUILD_DIR"
	else
		Log "Removing build area $BUILD_DIR"
		rm -Rf $BUILD_DIR
	fi
	Log "End of program reached"
}
