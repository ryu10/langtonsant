#!/usr/bin/bash

set -e

# cd to scriptDir
pushd . &> /dev/null
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd ${scriptDir}

# project-specific params
exeFile=langant
loadAddr=0x6000
diskImage=langant.po

# params
buildDir=build
acCmd=ac.sh
# cwd=$( pwd )
diskPath=${buildDir}/${diskImage}
exePath=${buildDir}/${exeFile}


# subtasks as functions
function mk_build_dir(){
  if [ ! -f ${buildDir}/build.ninja ]; then
      mkdir -p ${buildDir}
      pushd ${buildDir} &> /dev/null
      cmake -G Ninja -DCMAKE_TOOLCHAIN_FILE=../../utils/cc65-toolchain-example/toolchains/cc65-toolchain.cmake ..
      popd &> /dev/null
  fi
}

function build(){
  mk_build_dir
  # cmake --build build -- "$@"
  cmake --build ${buildDir} 
}

function clean(){
  if [ -d ${buildDir} ]; then
    cmake --build ${buildDir} -- "clean"
  else
    echo Directory ${buildDir} does not exist. Do nothing.
  fi
}

function writeDisk(){
  ${acCmd} -d ${diskPath} ${exeFile}
# for CC65 programs
#  ${acCmd} -as ${diskPath} ${exeFile} BIN ${loadAddr} < ${exePath} 
# for CA65 asm program
  ${acCmd} -p ${diskPath} ${exeFile} BIN ${loadAddr} < ${exePath} 
}

function disk(){
  if [ ! -e ${diskPath} ]; then # no *.po image file, create one
    ${acCmd} -pro140 ${diskPath} NONAME
    writeDisk
  elif [ ${exePath} -nt ${diskPath} ]; then # .po exists, and new exe was created
    writeDisk
  else
    echo ${diskImage} is newer than ${exeFile}. ${diskImage} is not updated. 
  fi
}

#
# other funcs come here
#

function all(){
  build
  disk
}

# main

# special case : no args at all
if [ $# -eq 0 ]; then
  all
  popd  &> /dev/null # from scriptdir
  exit 0
fi

# swtich loop
case $1 in
  all)
    all
    ;;
  build)
    build
    ;;
  disk)
    build
    disk
    ;;
  clean)
    clean
    ;;
  cleanall)
    clean
    if [ -d ${buildDir} ]; then
      rm -rf ${buildDir}
      echo $0 : Removed directory ${buildDir}.
    fi
    ;;
  *)
    echo $0 : unknown target $1
    exit 1
    ;;
esac

popd  &> /dev/null # from scriptDir