rule bqsr2:
    input:
        bam=f"{DATA}/bqsr1/{{sample}}.recal.bam",
        bai=f"{DATA}/bqsr1/{{sample}}.recal.bam.bai",
        known=f"{DATA}/variants_r2/final_variants_2.vcf.gz",
        ref=REF,
        dict=REF.replace(".fna",".dict")

    output:
        table=f"{DATA}/bqsr2/{{sample}}.recal.table"

    log:
        f"{DATA}/logs/bqsr2/{{sample}}.log"

    threads: 8

    conda:
        "../envs/gatk.yaml"

    shell:
        """
        set -euo pipefail
        mkdir -p {DATA}/bqsr2
        mkdir -p {DATA}/logs/bqsr2
        gatk --java-options "-Xmx8G" BaseRecalibrator \
            -R {input.ref} \
            -I {input.bam} \
            --known-sites {input.known} \
            -O {output.table} \
            > {log} 2>&1
        """
rule apply_bqsr2:
    input:
        bam=f"{DATA}/bqsr1/{{sample}}.recal.bam",
        bai=f"{DATA}/bqsr1/{{sample}}.recal.bam.bai",
        table=f"{DATA}/bqsr2/{{sample}}.recal.table",
        ref=REF

    output:
        bam=f"{DATA}/bqsr2/{{sample}}.recal.bam",
        bai=f"{DATA}/bqsr2/{{sample}}.recal.bam.bai"

    log:
        f"{DATA}/logs/apply_bqsr2/{{sample}}.log"

    threads: 8

    conda:
        "../envs/gatk.yaml"

    shell:
        """
        set -euo pipefail
        mkdir -p {DATA}/bqsr2
        mkdir -p {DATA}/logs/apply_bqsr2
        gatk --java-options "-Xmx8G" ApplyBQSR \
            -R {input.ref} \
            -I {input.bam} \
            --bqsr-recal-file {input.table} \
            -O {output.bam} \
            > {log} 2>&1
        samtools index {output.bam}
        """      

