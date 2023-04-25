# Bootstrap base system in stages

Requires: `mmdebstrap uidmap`

## Stage 1

Creae a base image of bare Devuan from its repos

```
cat << EOF | mmdebstrap > dynebolic-stage1.tar
deb http://deb.devuan.org/merged daedalus main
deb-src http://deb.devuan.org/merged daedalus main
EOF
```

TODO: command to archive all source packages.

## Stage 2

