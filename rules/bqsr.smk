rule bqsr1:
    input:
        bam=f"{DATA}/aligned/{{sample}}.rg.bam",
        bai=f"{DATA}/aligned/{{sample}}.rg.bam.bai",
        known=f"{DATA}/variants/final_variants_1.vcf.gz",
        ref=REF,
        dict=REF.replace(".fna",".dict")

    output:
        table=f"{DATA}/bqsr1/{{sample}}.recal.table"

    log:
        f"{DATA}/logs/bqsr1/{{sample}}.log"

    threads: 8

    conda:
        "../envs/gatk.yaml"

    shell:
        """
        mkdir -p {DATA}/bqsr1
        mkdir -p {DATA}/logs/bqsr1
        gatk --java-options "-Xmx8G" BaseRecalibrator \
            -R {input.ref} \
            -I {input.bam} \
            --known-sites {input.known} \
            --maximum-cycle-value 1000 \
            -O {output.table} \
            > {log} 2>&1
        """
rule apply_bqsr1:
    input:
        bam=f"{DATA}/aligned/{{sample}}.rg.bam",
        bai=f"{DATA}/aligned/{{sample}}.rg.bam.bai",
        table=f"{DATA}/bqsr1/{{sample}}.recal.table",
        ref=REF

    output:
        bam=f"{DATA}/bqsr1/{{sample}}.recal.bam",
        bai=f"{DATA}/bqsr1/{{sample}}.recal.bam.bai"

    log:
        f"{DATA}/logs/apply_bqsr/{{sample}}.log"

    threads: 8

    conda:
        "../envs/gatk.yaml"

    shell:
        """
        mkdir -p {DATA}/bqsr1
        mkdir -p {DATA}/logs/apply_bqsr
        gatk --java-options "-Xmx8G" ApplyBQSR \
            -R {input.ref} \
            -I {input.bam} \
            --bqsr-recal-file {input.table} \
            -O {output.bam} \
            > {log} 2>&1
        samtools index {output.bam}
        """
