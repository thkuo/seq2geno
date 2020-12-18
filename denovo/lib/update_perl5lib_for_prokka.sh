#!/usr/bin/env bash

echo 'current PERL5LIB='$PERL5LIB
if ! ( echo $PERL5LIB|grep -q $( dirname $( which prokka ) )/../perl5/ ); then
    echo 'start updating the variable for this environment...'
    # set up for this time
    export PERL5LIB_BACKUP=$PERL5LIB
    export PERL5LIB=$( dirname $( which prokka ) )/../perl5/:$PERL5LIB
    # automatically set it up next time
    cd $CONDA_PREFIX
    mkdir -p ./etc/conda/activate.d
    mkdir -p ./etc/conda/deactivate.d
    touch ./etc/conda/activate.d/env_vars.sh
    touch ./etc/conda/deactivate.d/env_vars.sh
    echo 'export PERL5LIB_BACKUP='$PERL5LIB >> ./etc/conda/activate.d/env_vars.sh
    echo 'export PERL5LIB='$( dirname $( which prokka ) )/../perl5/:$PERL5LIB >> ./etc/conda/activate.d/env_vars.sh
    # automatically restore 
    echo 'export PERL5LIB='$PERL5LIB_BACKUP >> ./etc/conda/deactivate.d/env_vars.sh
    echo 'unset PERL5LIB_BACKUP' >> ./etc/conda/deactivate.d/env_vars.sh
  else
    echo 'no update'
fi;
