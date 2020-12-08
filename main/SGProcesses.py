#' Role: Workers
#' Purpose: Define the class of workflow
class SGProcess:
    def __init__(self, wd, proc, 
                 config_f, dryrun= True, 
                 max_cores= 1, mem_mb=-1):
        import os
        import psutil
        self.proc= proc
        self.dryrun= dryrun
        self.config_f= config_f 
        #' check and adjust the core number setting
        cpu_count= int(psutil.cpu_count())
        if (max_cores > cpu_count) or (max_cores < 1):
            print(('The number of cpu was {}; cores setting '
                  'adjusted').format(str(cpu_count)))
            self.max_cores= max(int(cpu_count-1), 1)
        else:
            self.max_cores= int(max_cores)

        #' check and adjust the memory size setting
        freemem= psutil.virtual_memory().free/1e6
        if (mem_mb > freemem) or (mem_mb <= 0):
            print(('Currently free memory size was {}mb; memory setting '
                  'adjusted').format(str(freemem)))
            self.mem_mb= int(freemem * 0.8)
        else:
            self.mem_mb= int(mem_mb)
        
    def run_proc(self):
        proc= self.proc
        dryrun= True if self.dryrun == 'Y' else False
        max_cores= self.max_cores
        config_f= self.config_f
        import os
        import sys
        env_dict=self.EditEnv(proc)
        print(proc)
        try:
            import snakemake
            os.environ['PATH']=env_dict['PATH']

            ## run the process
            success=snakemake.snakemake(
                snakefile= env_dict['SNAKEFILE'],
                lock= False,
                restart_times= 3,
                cores= max_cores,
                resources= {'mem_mb': self.mem_mb}, 
                configfile=config_f,
                force_incomplete= True,
                workdir= os.path.dirname(config_f),
                use_conda=True,
                conda_prefix= os.path.join(env_dict['TOOL_HOME'], 'env'),
                dryrun= dryrun,
                printshellcmds= True,
                notemp=True
                )
            if not success:
                raise Exception('Snakemake workflow fails')
        except Exception as e:
            from datetime import datetime
            print('ERROR ({})'.format(proc))
            print('{}\t{}\n'.format(
                datetime.now().isoformat(' ',timespec= 'minutes'),
                e))
            raise RuntimeError(e)
        except :
            from datetime import datetime
            print('ERROR ({})'.format(proc))
            print('{}\t{}\n'.format(
                datetime.now().isoformat(' ',timespec= 'minutes'),
                sys.exc_info()))
            raise RuntimeError('Unknown problem occured when lauching Snakemake')

    def EditEnv(self, proc):
        import os
        import sys
        import re
        import pandas as pd
        from datetime import datetime
        script_dir=os.path.dirname(os.path.realpath(__file__))
        toolpaths_f=os.path.join(script_dir, 'ToolPaths.tsv')
        ## read the env variables
        env_df= pd.read_csv(toolpaths_f, sep= '\t', comment= '#', index_col= 0)
        env_series=pd.Series([])
        env_dict= {}
        try:
            #' ensure the most important variable
            assert 'SEQ2GENO_HOME' in os.environ
        except AssertionError :
            print('ERROR ({})'.format('SEQ2GENO_HOME'))
            print('{}\t{}\n'.format(
                datetime.now().isoformat(' ',timespec= 'minutes'),
                'SEQ2GENO_HOME not properly set'))
            sys.exit()

        try:
            env_series= env_df.loc[proc,:]
        except KeyError as ke:
            print('ERROR ({})'.format(proc))
            print('{}\t{}\n'.format(
                datetime.now().isoformat(' ',timespec= 'minutes'),
                'unavailable function'))
            sys.exit()
        else:
            try:
                os.environ['TOOL_HOME']= os.path.join(os.environ['SEQ2GENO_HOME'],
                        str(env_series['TOOL_HOME']))
                all_env_var= dict(os.environ)
                env_dict={'TOOL_HOME': all_env_var['TOOL_HOME']}
                for env in env_series.index.values.tolist():
                    if env == 'TOOL_HOME':
                        continue
                    val= str(env_series[env])
                    included= list(set(re.findall('\$(\w+)', val)))
                    for included_env in included:
                        val= re.sub('\$'+included_env, all_env_var[included_env], val)
                    env_dict[env]= val
            except:
                print('ERROR ({})'.format(proc))
                print('{}\t{}\n'.format(
                    datetime.now().isoformat(' ',timespec= 'minutes'),
                    'Unable to set environment variables'))
                sys.exit()
        return(env_dict)
