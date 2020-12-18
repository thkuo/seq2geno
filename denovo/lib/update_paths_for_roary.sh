#!/usr/bin/env bash

# the current settings
ROARY_HOME=$( dirname $( dirname $( which roary ) ) )
new_paths_count=0
#export PATH_BACKUP=$PATH
all_must=$( echo $ROARY_HOME/build/fasttree:$ROARY_HOME/build/mcl-14-137/src/alien/oxygen/src:$ROARY_HOME/build/mcl-14-137/src/shmcl:$ROARY_HOME/build/ncbi-blast-2.4.0+/bin:$ROARY_HOME/build/prank-msa-master/src:$ROARY_HOME/build/cd-hit-v4.6.6-2016-0711:$ROARY_HOME/build/bedtools2/bin:$ROARY_HOME/build/parallel-20160722/src | tr ':' ' ' )
for p in $all_must;do
  echo 'check '$p'...'
  if ! ( echo $PATH |grep -q $p ); then
      echo 'add the variable for this environment...'
      new_paths_count=$(($new_paths_count + 1))
      # set it up this time
      export PATH=$p:$PATH
  fi;
done

echo 'Total paths to update:'$new_paths_count
# automatically set it next time
if [ $new_paths_count -gt 0 ]; then
  cd $CONDA_PREFIX
  mkdir -p ./etc/conda/activate.d
  mkdir -p ./etc/conda/deactivate.d
  touch ./etc/conda/activate.d/env_vars.sh
  touch ./etc/conda/deactivate.d/env_vars.sh
  echo 'export PATH_BACKUP='$PATH >> ./etc/conda/activate.d/env_vars.sh
  echo 'export PATH='$( dirname $( which prokka ) )/../perl5/:$PATH >> ./etc/conda/activate.d/env_vars.sh
  # automatically restore 
  echo 'export PATH='$PATH_BACKUP >> ./etc/conda/deactivate.d/env_vars.sh
  echo 'unset PATH_BACKUP' >> ./etc/conda/deactivate.d/env_vars.sh
fi;
