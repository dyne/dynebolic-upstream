#/bin/bash
# execute on build system
# adds no-pager option to allow unattended dynebolic builds
patch /usr/share/mmdebstrap/hooks/eatmydata/customize.sh ./eatmydata-customize.sh.patch
