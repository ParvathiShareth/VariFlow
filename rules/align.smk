SE = "|".join(config["se_samples"])
PE = "|".join(config["pe_samples"])

DATA = config["data_dir"]
REF = config["reference"]

rule bwa_mem_pe:
    input:
        ref=REF,
        idx=REF + ".bwt",
        r1=f"{DATA}/fastq/{{sample}}_R1.fastq.gz",
        r2=f"{DATA}/fastq/{{sample}}_R2.fastq.gz"
    output:
        bam=f"{DATA}/aligned/{{sample}}.sorted.bam"
    wildcard_constraints:
        sample="|".join(config["pe_samples"])
    log:
        f"{DATA}/logs/bwa_mem_pe/{{sample}}.log"
    threads: 3
    conda:
        "../envs/bwa.yaml"
    shell:
        """
        mkdir -p {DATA}/aligned/tmp
        bwa mem -t {threads} \
        -R "@RG\\tID:{wildcards.sample}\\tSM:{wildcards.sample}\\tPL:ILLUMINA" \
        {input.ref} {input.r1} {input.r2} 2> {log} | \
        samtools sort -@ {threads} -m 300M \
        -T {DATA}/aligned/tmp \
        -o {output.bam} 2>> {log}
        """
rule bwa_mem_se:
    input:
        ref=REF,
        idx=REF + ".bwt",
        reads=f"{DATA}/fastq/{{sample}}.fastq.gz"
    output:
        bam=f"{DATA}/aligned/{{sample}}.sorted.bam"
    wildcard_constraints:
        sample="|".join(config["se_samples"])
    log:
        f"{DATA}/logs/bwa_mem_se/{{sample}}.log"
    threads: 3
    conda:
        "../envs/bwa.yaml"
    shell:
        """
        mkdir -p {DATA}/aligned/tmp
        bwa mem -t {threads} {input.ref} {input.reads} 2> {log} | \
        samtools sort -@ {threads} -m 300M \
        -T {DATA}/aligned/tmp \
        -o {output.bam} 2>> {log}
        """
