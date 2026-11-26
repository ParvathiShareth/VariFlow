rule download_sra:
    output:
        sra="outputs/sra/{sample}/{sample}.sra"
    shell:
        """
        mkdir -p outputs/sra/{wildcards.sample}
        
        prefetch {wildcards.sample} --max-size 100G
        
        mv {wildcards.sample}/{wildcards.sample}.sra {output.sra}
        
        rm -rf {wildcards.sample}
        """
