rule fasterq_se:
    input:
        sra=f"{DATA}/sra/{{sample}}/{{sample}}.sra"
    output:
        fastq=f"{DATA}/fastq/{{sample}}.fastq.gz"
    log:
        f"{DATA}/logs/fasterq/{{sample}}.log"
    threads: 2
    wildcard_constraints:
        sample="|".join(SE_SAMPLES)
    shell:
        """
        mkdir -p {DATA}/fastq
        # remove old files
        rm -f {DATA}/fastq/{wildcards.sample}*
        fastq-dump {input.sra} \
            --gzip \
            -O {DATA}/fastq \
            2> {log}
        """
rule fasterq_pe:
    input:
        sra=f"{DATA}/sra/{{sample}}/{{sample}}.sra"
    output:
        R1=f"{DATA}/fastq/{{sample}}_R1.fastq.gz",
        R2=f"{DATA}/fastq/{{sample}}_R2.fastq.gz"
    log:
        f"{DATA}/logs/fasterq/{{sample}}.log"
    threads: 2
    wildcard_constraints:
        sample="|".join(PE_SAMPLES)
    shell:
        """
        mkdir -p {DATA}/fastq
        # remove old files
        rm -f {DATA}/fastq/{wildcards.sample}*

        fastq-dump {input.sra} \
            --split-files \
            --gzip \
            -O {DATA}/fastq \
            2> {log}
        if [ -f {DATA}/fastq/{wildcards.sample}_1.fastq.gz ]; then
            mv {DATA}/fastq/{wildcards.sample}_1.fastq.gz {output.R1}
            mv {DATA}/fastq/{wildcards.sample}_2.fastq.gz {output.R2}
        else
            echo "ERROR: Paired files not generated" >> {log}
            exit 1
        fi
        """
