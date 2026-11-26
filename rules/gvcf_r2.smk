rule haplotypecaller_r2:
    input:
        bam=f"{DATA}/bqsr1/{{sample}}.recal.bam",
        bai=f"{DATA}/bqsr1/{{sample}}.recal.bam.bai",
        ref=REF

    output:
        gvcf=f"{DATA}/variants_r2/{{sample}}.g.vcf.gz",
        tbi=f"{DATA}/variants_r2/{{sample}}.g.vcf.gz.tbi"

    log:
        f"{DATA}/logs/haplotypecaller_r2/{{sample}}.log"

    threads: 8

    conda:
        "../envs/gatk.yaml"

    shell:
        """
        set -euo pipefail
        mkdir -p {DATA}/variants_r2
        mkdir -p {DATA}/logs/haplotypecaller_r2
        gatk HaplotypeCaller \
            -R {input.ref} \
            -I {input.bam} \
            -O {output.gvcf} \
            -ERC GVCF \
            --sample-name {wildcards.sample} \
            > {log} 2>&1
        gatk IndexFeatureFile -I {output.gvcf} \
            >> {log} 2>&1
        """
rule genomicsdb_r2:
    input:
        gvcfs=expand(f"{DATA}/variants_r2/{{sample}}.g.vcf.gz", sample=SAMPLES),
        tbis=expand(f"{DATA}/variants_r2/{{sample}}.g.vcf.gz.tbi", sample=SAMPLES),
        intervals=f"{DATA}/data/reference/genome.intervals"
    output:
        db=directory(f"{DATA}/variants_r2/db")
    params:
        gvcfs=lambda wc, input: " ".join(["-V " + f for f in input.gvcfs])
    threads: 8
    conda:
        "../envs/gatk.yaml"
    shell:
        """
        gatk GenomicsDBImport \
            --genomicsdb-workspace-path {output.db} \
            --batch-size 50 \
            --reader-threads {threads} \
            -L {input.intervals} \
            {params.gvcfs} \
            --tmp-dir /tmp
        """
rule genotype_r2:
    input:
        db=f"{DATA}/variants_r2/db",
        ref=REF
    output:
        vcf=f"{DATA}/variants_r2/final_variants_2.vcf.gz"
    log:
        f"{DATA}/logs/genotype_r2/genotype.log"
    threads: 8
    conda:
        "../envs/gatk.yaml"
    shell:
        """
        gatk --java-options "-Xmx8G" GenotypeGVCFs \
            -R {input.ref} \
            -V gendb://{input.db} \
            -O {output.vcf}
        """
