include: os.path.join(RULE_LIB_DIR, 'index_vcf', 'index_vcf.smk')
include: os.path.join(RULE_LIB_DIR, 'create_vcf', 'create_vcf.smk')
include: os.path.join(RULE_LIB_DIR, 'index_bam', 'index_bam.smk')
#include: os.path.join(RULE_LIB_DIR, 're_redirect_bwa_result', 're_redirect_bwa_result.smk')
#include: os.path.join(RULE_LIB_DIR, 'tr_single_mapping', 'tr_single_mapping.smk')
#include: os.path.join(RULE_LIB_DIR, 'tr_paired_mapping', 'tr_paired_mapping.smk')
include: os.path.join(RULE_LIB_DIR, 'tr_mapping', 'tr_mapping.smk')
