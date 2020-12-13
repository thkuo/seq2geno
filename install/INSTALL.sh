## ensure conda channels
for c in hzibifo hzi-bifo conda-forge/label/broken bioconda conda-forge defaults; do 
	if [ $(conda config --get channels | grep $c | wc -l) -eq 0 ]; then
		conda config --add channels $c
	fi
done
### clone seq2geno
#git clone --recurse-submodules https://github.com/hzi-bifo/seq2geno.git
#cd seq2geno
#export SEQ2GENO_HOME=$( realpath . )
#git submodule update --init --recursive
#
### download the core environment
#cd install
#conda env create -n snakemake_env --file=snakemake_env.yml
#cd ..
#
### set up environmental variables
#conda activate snakemake_env
#cd $CONDA_PREFIX
#mkdir -p ./etc/conda/activate.d
#mkdir -p ./etc/conda/deactivate.d
#export ACTIVATE_ENVVARS=./etc/conda/activate.d/env_vars.sh
#export DEACTIVATE_ENVVARS=./etc/conda/deactivate.d/env_vars.sh
#touch $ACTIVATE_ENVVARS
#touch $DEACTIVATE_ENVVARS
#
#echo 'export SEQ2GENO_HOME='$SEQ2GENO_HOME >> $ACTIVATE_ENVVARS
#echo 'export PATH_BACKUP='$PATH >> $ACTIVATE_ENVVARS
#echo 'export PATH='$SEQ2GENO_HOME/main:$PATH >> $ACTIVATE_ENVVARS
#
#echo 'unset $SEQ2GENO_HOME' >> $DEACTIVATE_ENVVARS
#echo 'export $PATH=$PATH_BACKUP' >> $DEACTIVATE_ENVVARS
#echo 'unset $PATH_BACKUP'  >> $DEACTIVATE_ENVVARS
#conda deactivate
#
### decompress the example dataset to install the process-specific environments

