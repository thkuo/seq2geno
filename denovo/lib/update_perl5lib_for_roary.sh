#!/usr/bin/env bash

# the current settings
ROARY_HOME=$( dirname $( dirname $( which roary ) ) )
new_paths_count=0
export PERL5LIB_BACKUP=$PERL5LIB
for p in $ROARY_HOME/lib $ROARY_HOME/build/bedtools2/lib; do
  echo 'check '$p'...'
  if ! ( echo $PERL5LIB |grep -q $p ); then
      echo 'add the variable for this environment...'
      new_paths_count=$(($new_paths_count + 1))
      # set it up this time
      export PERL5LIB=$p:$PERL5LIB
  fi;
done

# automatically set it next time
if [ $new_paths_count -gt 0 ]; then
  cd $CONDA_PREFIX
  mkdir -p ./etc/conda/activate.d
  mkdir -p ./etc/conda/deactivate.d
  touch ./etc/conda/activate.d/env_vars.sh
  touch ./etc/conda/deactivate.d/env_vars.sh
  echo 'export PERL5LIB_BACKUP='$PERL5LIB_BACKUP >> ./etc/conda/activate.d/env_vars.sh
  echo 'export PERL5LIB='$PERL5LIB >> ./etc/conda/activate.d/env_vars.sh
  # automatically restore 
  echo 'export PERL5LIB='$PERL5LIB_BACKUP >> ./etc/conda/deactivate.d/env_vars.sh
  echo 'unset PERL5LIB_BACKUP' >> ./etc/conda/deactivate.d/env_vars.sh
fi;
