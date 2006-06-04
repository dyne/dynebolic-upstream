# dyne:II network shell library
# (C)2006 Denis "Jaromil" Roio
# GNU GPL License

source /lib/dyne/utils.sh

open_network_resource() {
  # open a resource firing up the appropriate application
  # supported resource urls:
  # http:// ftp:// ssh:// smb://
  if [ -z $1 ]; then
    return
  fi

  resource=$1

  ##########################################
  ## HTTP
  if [ ${resource[0,7]} = "http://" ]; then

    www $resource

  ##########################################
  ## FTP
  elif [ ${resource[0,6]} = "ftp://" ]; then

    gftp $resource &

  ##########################################
  ## SSH
  elif [ ${resource[0,6]} = "ssh://" ]; then

    dynemount_ssh $resource

  ##########################################
  ## SMB
  elif [ ${resource[0,6]} = "smb://" ]; then

    dynemount_smb $resource

  else
    ## Unknown resource type
    error_dialog "Cannot open unkown network resource: ${resource}"

  fi

}
