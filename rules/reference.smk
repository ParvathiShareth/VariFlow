REF = config["reference"]

rule bwa_index:
    input:
        ref=REF
    output:
        amb=REF + ".amb",
        ann=REF + ".ann",
        bwt=REF + ".bwt",
        pac=REF + ".pac",
        sa=REF + ".sa"
    log:
        f"{DATA}/logs/bwa_index.log"
    conda:
        "../envs/bwa.yaml"
    shell:
        """
        mkdir -p {DATA}/logs
        bwa index {input.ref} > {log} 2>&1
        """

rule faidx:
    input:
        ref=REF
    output:
        REF + ".fai"
    conda:
        "../envs/samtools.yaml"
    shell:
        """
        samtools faidx {input.ref}
        """

rule dict:
    input:
        ref=REF
    output:
        REF.replace(".fna",".dict")
    conda:
        "../envs/gatk.yaml"
    shell:
        """
        gatk CreateSequenceDictionary \
        -R {input.ref} \
        -O {output}
        """
