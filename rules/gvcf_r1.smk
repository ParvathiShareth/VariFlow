DATA = config["data_dir"]
REF = config["reference"]

rule haplotypecaller_r1:
    input:
        bam=f"{DATA}/aligned/{{sample}}.rg.bam",
        bai=f"{DATA}/aligned/{{sample}}.rg.bam.bai",
        ref=REF,
        fai=REF + ".fai",
        dict=REF.replace(".fna",".dict")
        
    output:
        gvcf=f"{DATA}/variants/{{sample}}.g.vcf.gz",
        tbi=f"{DATA}/variants/{{sample}}.g.vcf.gz.tbi"

    log:
        f"{DATA}/logs/haplotypecaller/{{sample}}.log"

    threads: 8

    conda:
        "../envs/gatk.yaml"

    shell:
        """
        set -euo pipefail
        mkdir -p {DATA}/variants
        mkdir -p {DATA}/logs/haplotypecaller
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


rule genomicsdb_import:
    input:
        gvcfs=lambda wildcards: expand(f"{DATA}/variants/{{sample}}.g.vcf.gz", sample=SAMPLES),
        tbis=lambda wildcards: expand(f"{DATA}/variants/{{sample}}.g.vcf.gz.tbi", sample=SAMPLES),
        intervals="data/reference/genome.intervals"

    output:
        db_dir=directory(f"{DATA}/variants/genomicsdb")

    log:
        f"{DATA}/logs/genomicsdb_import/genomicsdb.log"

    params:
        gvcfs=lambda wildcards, input: " ".join(f"-V {f}" for f in input.gvcfs)

    threads: 8

    conda:
        "../envs/gatk.yaml"

    shell:
        """
        set -euo pipefail
        mkdir -p {DATA}/logs/genomicsdb_import
        # IMPORTANT: remove old DB if exists
        rm -rf {output.db_dir}
        gatk GenomicsDBImport \
            --genomicsdb-workspace-path {output.db_dir} \
            --batch-size 50 \
            --reader-threads {threads} \
            --merge-input-intervals \
            -L {input.intervals} \
            {params.gvcfs} \
            --tmp-dir /tmp \
            > {log} 2>&1
        """

rule genotype_from_db:
    input:
        db_dir=f"{DATA}/variants/genomicsdb",
        ref=REF,
        fai=REF + ".fai",
        dict=REF.replace(".fna",".dict")

    output:
        vcf=f"{DATA}/variants/final_variants_1.vcf.gz"

    log:
        f"{DATA}/logs/genotype_from_db/genotype.log"

    conda:
        "../envs/gatk.yaml"

    shell:
        """
        set -euo pipefail
        mkdir -p {DATA}/logs/genotype_from_db
        mkdir -p {DATA}/variants
        gatk GenotypeGVCFs \
            -R {input.ref} \
            -V gendb://{input.db_dir} \
            -O {output.vcf} \
            > {log} 2>&1
        """
