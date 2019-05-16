## import a list
import pandas as pd
from snakemake.utils import validate

list_f= config['list_f']
dna_reads= {}
with open(list_f, 'r') as list_fh:
    for l in list_fh:
        d=l.strip().split('\t')
        dna_reads[d[0]]= d[1].split(',')

strains= list(dna_reads.keys())

ref_fasta=config['ref_fasta']
ref_gbk=config['ref_gbk']
annot_tab=config['annot_tab']
r_annot=config['r_annot']
snps_table=config['snps_table']
snps_aa_table=config['snps_aa_table']
nonsyn_snps_aa_table=config['nonsyn_snps_aa_table']
snps_aa_bin_mat=config['snps_aa_bin_mat']
nonsyn_snps_aa_bin_mat=config['nonsyn_snps_aa_bin_mat']
adaptor_f= config['adaptor']
new_reads_dir= config['new_reads_dir']
table_subset_num=30

rule all:
    input:
        snps_aa_bin_mat,
        nonsyn_snps_aa_bin_mat,
        expand('{in_tab}_{info}', 
            in_tab= [snps_aa_bin_mat, nonsyn_snps_aa_bin_mat], 
            info= ['GROUPS', 'NONRDNT'])

rule remove_redundant_feat:
    input: 
        F='{in_tab}'
    output: 
        GROUPS='{in_tab}_GROUPS',
        NONRDNT='{in_tab}_NONRDNT'
    conda: 'cmpr_env.yaml'
    script: 'featCompress.py'

rule create_binary_table:
    input:
        snps_aa_table=snps_aa_table,
        nonsyn_snps_aa_table=nonsyn_snps_aa_table
    output:
        snps_aa_bin_mat=snps_aa_bin_mat,
        nonsyn_snps_aa_bin_mat=nonsyn_snps_aa_bin_mat
#    conda: 'py27.yml'
    params:
        parse_snps_tool= 'parse_snps.py'
    threads: 1
    shell:
        '''
        {params.parse_snps_tool} {input.snps_aa_table} \
{output.snps_aa_bin_mat} 
        {params.parse_snps_tool} {input.nonsyn_snps_aa_table} \
{output.nonsyn_snps_aa_bin_mat} 
        '''

rule create_table:
    input:
        flt_vcf=expand('{strain}.flt.vcf', strain= strains),
        flatcount=expand('{strain}.flatcount', strain= strains),
        dict_file='dict.txt',
        ref_gbk=ref_gbk,
        annofile=annot_tab
    output:
        snps_table=snps_table
    conda: 'snps_tab_mapping.yml'
    params:
        split_tool='split_for_mutation_table.py',
        isol_subset_num= table_subset_num,
        isol_subset_top= table_subset_num-1,
        isol_subset_dir= 'isols_subset',
        mut_tab_tool= 'mutation_table.py',
        snps_subset_dir= 'snps_subset'
    shadow: "shallow"
    threads: 30
    shell:
        '''
        if [ ! -d {params.isol_subset_dir} ]; then
          mkdir -p {params.isol_subset_dir};
        fi
        if [ ! -d {params.snps_subset_dir} ]; then
          mkdir -p {params.snps_subset_dir};
        fi
        {params.split_tool} {input.dict_file} \
 {params.isol_subset_num} \
 {params.isol_subset_dir}

        for i in {{0..{params.isol_subset_top}}}; \
do echo "{params.mut_tab_tool} -f <(cat {input.dict_file} ) \
 -a {input.annofile} \
 -o {params.snps_subset_dir}/all_snps_$i.txt \
 --restrict_samples {params.isol_subset_dir}/isols_${{i}}.txt\
 --force_homozygous"; done \
| parallel -j {threads} --joblog {params.snps_subset_dir}/joblog_mutation_table.txt

        i=$(for i in {{0..{params.isol_subset_top}}}; \
 do echo -n " <(cut -f5-  {params.snps_subset_dir}/all_snps_${{i}}.txt)"; done)

        echo "paste <(cut -f1-4  {params.snps_subset_dir}/all_snps_0.txt )  $i\
> {output.snps_table}" | bash
        '''

rule include_aa_into_table:
    input:
        ref_gbk=ref_gbk,
        snps_table=snps_table
    output:
        snps_aa_table=snps_aa_table,
        nonsyn_snps_aa_table=nonsyn_snps_aa_table
    conda: 'snps_tab_mapping.yml'
    params:
        to_aa_tool= 'Snp2Amino.py' 
    threads: 1
    shell:
        """
        {params.to_aa_tool} -f {input.snps_table} -g {input.ref_gbk} \
-n all -o {output.snps_aa_table}
        awk '{{if($6 != "none" && $5 != $6){{print $0}}}}' {output.snps_aa_table} > \
{output.nonsyn_snps_aa_table}
        """


rule isolate_dict:
    input:
        flt_vcf=expand('{strain}.flt.vcf', strain= strains),
        flatcount=expand('{strain}.flatcount', strain= strains)
    output:
        dict_file='dict.txt'
    threads:1
    wildcard_constraints:
        strain='^[^\/]+$'
    params:
        strains= strains
    run:
        import re
        import os
        ## list and check all required files
        try:
            empty_files= [f for f in input if os.path.getsize(f)==0]
            if len(empty_files) > 0:
                raise Exception('{} should not be empty'.format(
','.join(empty_files)))
        except Exception as e:
            sys.exit(str(e))
        
        with open(output[0], 'w') as out_fh:
            out_fh.write('\n'.join(params.strains))
        
rule my_samtools_SNP_pipeline:
    input:
        sam='{strain}.sam',
        reffile=ref_fasta
    output:
        bam=temp('{strain}.bam'),
        raw_bcf='{strain}.raw.bcf',
        flt_vcf='{strain}.flt.vcf'
    threads:1
    conda: 'snps_tab_mapping.yml'
    shell:
        """
        sleep 10
        export PERL5LIB=$CONDA_PREFIX/lib/perl5/site_perl/5.22.0:\
$CONDA_PREFIX/lib/perl5/5.22.2:\
$CONDA_PREFIX/lib/perl5/5.22.2/x86_64-linux-thread-multi/:\
$PERL5LIB
        echo $PERL5LIB
        my_samtools_SNP_pipeline {wildcards.strain} {input.reffile} 0
        """

rule my_stampy_pipeline_PE:
    input:
        infile1= lambda wildcards: os.path.join(
        new_reads_dir, '{}.cleaned.1.fq.gz'.format(wildcards.strain)),
        infile2= lambda wildcards: os.path.join(
        new_reads_dir, '{}.cleaned.2.fq.gz'.format(wildcards.strain)),
        reffile=ref_fasta,
        ref_index_stampy=ref_fasta+'.stidx',
        ref_index_bwa=ref_fasta+'.bwt',
        annofile=annot_tab,
        Rannofile=r_annot
    output:
        sam=temp('{strain}.sam'),
        art='{strain}.art',
        sin='{strain}.sin',
        flatcount='{strain}.flatcount',
        rpg='{strain}.rpg',
        stat='{strain}.stats'
    threads:1
    conda: 'snps_tab_mapping.yml'
    shell:
        """
        sleep 10
        export PERL5LIB=$CONDA_PREFIX/lib/perl5/5.22.2/x86_64-linux-thread-multi/:$PERL5LIB
        export PERL5LIB=$CONDA_PREFIX/lib/perl5/5.22.2:$PERL5LIB
        export PERL5LIB=$CONDA_PREFIX/lib/perl5/site_perl/5.22.0:$PERL5LIB
        my_stampy_pipeline_PE {wildcards.strain} \
{input.infile1} {input.infile2} {input.reffile} \
{input.annofile} {input.Rannofile} 2> {wildcards.strain}.log
        """

rule redirect_and_preprocess_reads:
    input: 
        infile1=lambda wildcards: dna_reads[wildcards.strain][0],
        infile2=lambda wildcards: dna_reads[wildcards.strain][1]
    output:
        log_f= os.path.join(new_reads_dir, '{strain}.log'),
        f1= os.path.join(new_reads_dir, '{strain}.cleaned.1.fq.gz'),
        f2= os.path.join(new_reads_dir, '{strain}.cleaned.2.fq.gz')
    params:
        adaptor_f= adaptor_f,
        tmp_f1= lambda wildcards: os.path.join(
            new_reads_dir, '{}.cleaned.1.fq'.format(wildcards.strain)),
        tmp_f2= lambda wildcards: os.path.join(
            new_reads_dir, '{}.cleaned.2.fq'.format(wildcards.strain))
    shell:
        '''
        if [ -e "{params.adaptor_f}" ]
        then
            fastq-mcf -l 50 -q 20 {params.adaptor_f} {input.infile1} {input.infile2} \
  -o {params.tmp_f1} -o {params.tmp_f2} > {output.log_f}
            gzip -9 {params.tmp_f1}
            gzip -9 {params.tmp_f2}
        else
            echo 'Reads not trimmed'
            echo 'No trimming' > {output.log_f}
            echo $(readlink {input.infile1}) >> {output.log_f}
            echo $(readlink {input.infile2}) >> {output.log_f}
            cp {input.infile1} {output.f1}
            cp {input.infile2} {output.f2}
        fi
        '''

rule create_annot:
    input:
        ref_gbk=ref_gbk
    output:
        anno_f=annot_tab
    params:
        ref_name='reference'
    shell:
        '''
        create_anno.py -r {input.ref_gbk} -n {params.ref_name} -o {output.anno_f}
        '''

rule create_r_annot:
    input:
        ref_gbk=ref_gbk
    output:
        R_anno_f=r_annot
    shell:
        '''
        create_R_anno.py -r {input.ref_gbk} -o {output.R_anno_f}
        '''

rule stampy_index_ref:
    input:
        reffile=ref_fasta
    output:
        ref_fasta+'.bwt',
        ref_fasta+'.stidx',
        ref_fasta+'.sthash'
    conda: 'snps_tab_mapping.yml'
    shell:
        '''
        stampy.py -G {input.reffile} {input.reffile}
        stampy.py -g {input.reffile} -H {input.reffile}
        bwa index -a bwtsw {input.reffile}
        '''
