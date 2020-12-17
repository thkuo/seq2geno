#!/usr/bin/env bash

if ! ( echo $PERL5LIB|grep -q $( dirname $PROKKA_BIN )/../perl5/ ); then
    cd $CONDA_PREFIX
    mkdir -p ./etc/conda/activate.d
    mkdir -p ./etc/conda/deactivate.d
    touch ./etc/conda/activate.d/env_vars.sh
    touch ./etc/conda/deactivate.d/env_vars.sh
    echo 'export PERL5LIB_BACKUP=$PERL5LIB' >> ./etc/conda/activate.d/env_vars.sh
    echo 'export PERL5LIB='$( dirname $( which prokka ) )/../perl5/:$PERL5LIB >> ./etc/conda/activate.d/env_vars.sh

    echo 'export PERL5LIB=$PERL5LIB_BACKUP' >> ./etc/conda/deactivate.d/env_vars.sh
    echo 'unset PERL5LIB_BACKUP' >> ./etc/conda/deactivate.d/env_vars.sh
fi;
