
def test_dna_reads_list(f):
    print('Checking the DNA-seq list...')
    import os
    #' the file should exist
    assert os.path.isfile(f)
    with open(f, 'r') as fh:
        for l in fh.readlines():
            #' the two columns 
            d= l.strip().split('\t')
            assert len(d)==2
            print(d[0])
            #' the files should be paired
            r_pair_files= d[1].split(',')
            #' the listed paths should exist
            assert os.path.isfile(r_pair_files[0])
            assert os.path.isfile(r_pair_files[1])

    return(0)

def test_rna_reads_list(f):
    print('Checking the RNA-seq list...')
    import os
    #' the file should exist
    assert os.path.isfile(f)
    with open(f, 'r') as fh:
        for l in fh.readlines():
            #' the two columns 
            d= l.strip().split('\t')
            assert len(d)==2
            print(d[0])
            #' the files should be paired
            r_file= d[1]
            #' the listed paths should exist
            assert os.path.isfile(r_file)
    return(0)

def test_reference_seq(f):
    print('Checking the reference sequences...')
    from Bio import SeqIO
    #' ensure a single sequence formatted in fasta
    seq_dict= SeqIO.to_dict(SeqIO.parse(f, 'fasta'))
    assert len(seq_dict) == 1
    return(0)

def test_functions(funcs_d):
    #' choices
    choices_dict= {'denovo': ['Y', 'N'], 
                   'snps': ['Y', 'N'], 
                   'expr': ['Y', 'N'],
                   'phylo': ['Y', 'N'],
                   'de': ['Y', 'N'], 
                   'ar': ['Y', 'N']}

    for k in funcs_d:
        #' ensure understoodable function
        assert k in choices_dict
        #' ensure the choice
        assert funcs_d[k] in choices_dict[k]

    return(0)
