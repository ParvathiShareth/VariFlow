rule haplotypecaller_r3:
    input:
        bam=f"{DATA}/bqsr2/{{sample}}.recal.bam",
        bai=f"{DATA}/bqsr2/{{sample}}.recal.bam.bai",
        ref=REF
    output:
        gvcf=f"{DATA}/variants_r3/{{sample}}.g.vcf.gz",
        tbi=f"{DATA}/variants_r3/{{sample}}.g.vcf.gz.tbi"
    threads: 8
    conda:
        "../envs/gatk.yaml"
    shell:
        """
        mkdir -p {DATA}/variants_r3
        gatk HaplotypeCaller \
        -R {input.ref} \
        -I {input.bam} \
        -O {output.gvcf} \
        -ERC GVCF \
        --sample-name {wildcards.sample}
        gatk IndexFeatureFile -I {output.gvcf}
        """
rule genomicsdb_r3:
    input:
        gvcfs=expand(f"{DATA}/variants_r3/{{sample}}.g.vcf.gz", sample=SAMPLES),
        tbis=expand(f"{DATA}/variants_r3/{{sample}}.g.vcf.gz.tbi", sample=SAMPLES),
        intervals="data/reference/genome.intervals"

    output:
        db=directory(f"{DATA}/variants_r3/db")

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
            --merge-input-intervals \
            -L {input.intervals} \
            {params.gvcfs} \
            --tmp-dir /tmp
        """
rule genotype_r3:
    input:
        db=f"{DATA}/variants_r3/db",
        ref=REF
    output:
        vcf=f"{DATA}/variants_r3/final_variants_3.vcf.gz"
    log:
        f"{DATA}/logs/genotype_r3/genotype.log"
    conda:
        "../envs/gatk.yaml"
    shell:
        """
        gatk GenotypeGVCFs \
        -R {input.ref} \
        -V gendb://{input.db} \
        -O {output.vcf}
        """          
