#!/bin/sh

KEYWORDS="STUB:|WARNING:|TODO:|FIXME:|DevTeam:|\?\?\?:" 
find "${SRCROOT}" \( -name "*.h" -or -name "*.m" -or -name "*.swift" \) -not -path "${SRCROOT}/Pods/*" -print0 | xargs -0 egrep --with-filename --line-number --only-matching "($KEYWORDS).*\$" | perl -p -e "s/($KEYWORDS)/1: warning: \$1/"

KEYWORDS="ERROR:|XXX:|\!\!\!:" 
find "${SRCROOT}" \( -name "*.h" -or -name "*.m" -or -name "*.swift" \) -not -path "${SRCROOT}/Pods/*" -print0 | xargs -0 egrep --with-filename --line-number --only-matching "($KEYWORDS).*\$" | perl -p -e "s/($KEYWORDS)/1: error: \$1/"
ERROR_OUTPUT=`find "${SRCROOT}" \( -name "*.h" -or -name "*.m" -or -name "*.swift" \) -not -path "${SRCROOT}/Pods/*" -print0 | xargs -0 egrep --with-filename --line-number --only-matching "($KEYWORDS).*\$" | perl -p -e "s/($KEYWORDS)/1: error: \$1/"`

exit ${#ERROR_OUTPUT}
