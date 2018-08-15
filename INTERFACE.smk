import pandas as pd
import os
import re
configfile: "config.yaml"
SAMPLES_DF=pd.read_table(config["samples"], sep= '\t', header= 0).set_index("strain", drop=False)
STRAINS=SAMPLES_DF['strain'].tolist()
REF_FA=config['reference_sequence']
REF_GBK=config['reference_annotation']
TMP_D=(config['tmp_d'] if re.search('\w', config['tmp_d']) else '.')
CORES=config['cores']
STAMPY_EXE=config['stampy_exe']
RAXML_EXE=config['raxml_exe']
RESULT_D=config['result_d']
#SOFTWARE={'mapper': 'bwa'}
SOFTWARE= config['software']
SOFTWARE['annotator']= 'prokka'
SOFTWARE['gene_sorter']= 'roary'
print(SAMPLES_DF)
print(SOFTWARE)

include: "CREATE_INDEL_TABLE.smk"
include: "CREATE_SNPS_TABLE.smk"
include: "CREATE_EXPR_TABLE.smk"
include: "CREATE_GPA_TABLE.smk"
include: "COUNT_GPA.smk"
include: "CONSTRUCT_ASSEMBLY.smk"
include: "MAKE_CONS.smk"
include: "INFER_TREE.smk"
include: "DETECT_SNPS.smk"

rule all:
    input:
        config['tree'],
        #config['expr_table'],
        #config['syn_snps_table'],
        #config['nonsyn_snps_table'],
        config['indel_table'],
        config['gpa_table']
        
