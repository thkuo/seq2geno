'''
Purpose:
    Accept and parse the user options
'''

import os
import argparse


def is_default_file(f):
    outcome= (True if f is None else False)
    return (outcome)

def option_rules(args):
    '''
    Check option conflict and dependency
    '''

def main():

    arg_formatter = lambda prog: argparse.RawTextHelpFormatter(prog,
            max_help_position=4, width = 80)

    parser = argparse.ArgumentParser(
            formatter_class= arg_formatter,
            description='Seq2Geno: the pipline tool '
                'for genomic features computation\n'
                '(Note: all directories and files are relative '
                'to the working directory)')

    parser.add_argument('-v', action= 'version', 
        version='v.Beta')

    ## project
    project_arg= parser.add_argument_group('project')
    project_arg.add_argument('--wd', dest= 'wd', required= True, 
        help='working directory')
    project_arg.add_argument('--cores', dest= 'cores', default= 1,
        help='number of cpus')
    project_arg.add_argument('-dryrun', dest= 'dryrun', action= 'store_true',
        help='only show the processes')
    project_arg.add_argument('--adaptor_f', dest= 'adaptor',type= str,
        default= '-',
        help='if the reads need to be cleaned, '
        'please specify the file that contains adaptors')

    ## samples
    sam_arg= parser.add_argument_group('samples')
    sam_arg.add_argument('--dna-reads', dest='dna_reads', type= str,
        help='list of samples and dna sequencing reads', default= '-', 
        required= True)
    sam_arg.add_argument('--rna-reads', dest='rna_reads', type= str,
        help='list of samples and rna sequencing reads', default= '-')
    sam_arg.add_argument('--pheno', dest='phe_table', type= str,
        help='list of sample pheno types', default= '-')

    ## reference
    ref_arg= parser.add_argument_group('reference')
    ref_arg.add_argument('--ref-fa', dest='ref_fa', type= str,
        help='reference genome sequences (fasta)', default= '-')
    ref_arg.add_argument('--ref-gbk', dest='ref_gbk', type= str,
        help='reference genome annotation (genbank)', default= '-')
    ref_arg.add_argument('--ref-gff', dest='ref_gff', type= str,
        help='reference genome annotation (gff3)', default= '-')

    ## core functions
    func_arg= parser.add_argument_group('functions')
    func_arg.add_argument('-e', dest='expr', action= 'store_true',
        default= False, 
        help='count expression levels')
    func_arg.add_argument('-d', dest='denovo', action= 'store_true',
        default= False, 
        help='create de novo assemblies and count gene contents')
    func_arg.add_argument('-s', dest='snps', action= 'store_true',
        default= False, 
        help='detect variants')
    func_arg.add_argument('-p', dest='phylo', action= 'store_true',
        default= False, 
        help='infer phylogenetic tree')

    ## expr
    expr_arg= parser.add_argument_group('expr')
    expr_arg.add_argument('-de', dest='de', action= 'store_true',
        default= False, help='differential expression analysis')
    expr_arg.add_argument('-ar', dest='ar', action= 'store_true',
        default= False, help='ancestral reconstruction')

    ######
    #####
    args, unknown = parser.parse_known_args()
    args.cores= int(args.cores)
#    print(args)
#    option_rules(args)

    return(args)
