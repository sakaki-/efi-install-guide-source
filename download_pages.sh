#!/bin/bash
#
# A trivial script to download the source for a list of wiki pages
# from the Gentoo wiki, and save them in the specified files.
#
# Takes one argument, the filename of the page source file. This file
# should contain one line per file to download. Each line should have
# the page name from the wiki, followed by a space, followed by the
# filename to save to.
#
# So you could run e.g.
#   ./download_pages.sh pages.txt
# when in the repo directory, to manually update the pages. Once you
# have done this, a "git diff" will show you what has changed.
#
# The script will remove unnecessary HTML from the fetched page, such
# that if the resulting content were to be pasted back into the 'edit'
# field on the Gentoo wiki for that page, no change would be detected.
#
# The Gentoo wiki could change at any time leaving the scraping
# process used by this script invalid, so do not use it for any
# critical production purpose!
#
# Copyright (c) 2018 sakaki <sakaki@deciban.com>
#
# License (GPL v3.0)
# ------------------
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

set -e
set -u

BASE_URL="https://wiki.gentoo.org/index.php?title="
URL_ACTION="&action=edit"

while read -r LN; do
	# TODO - would be better not to use space as the separator! 
	SUB_URL="$(cut <<<${LN} -d' ' -f1)"
	TO_FILENAME="$(cut <<<${LN} -d' ' -f2)"
	echo -n "${TO_FILENAME} ... "
	rm -f "${TO_FILENAME}"
	DATA="$(wget -q -O - "${BASE_URL}${SUB_URL}${URL_ACTION}")"
	# convert '<' chars
	DATA="${DATA//&lt;/<}"
	# convert '&' chars
	DATA="${DATA//&amp;/&}"
	# drop trailing content from close of textarea
	DATA="${DATA%%</textarea*}"
	# and drop content leading up to textarea
	DATA="${DATA##*<textarea}"
	DATA="${DATA#*>}"
	# finally, output
	echo "${DATA}" > "${TO_FILENAME}"
	echo "OK"
done < "$1"

