rule fix_readgroups:
    input:
        bam=f"{DATA}/aligned/{{sample}}.markdup.bam"
    output:
        bam=f"{DATA}/aligned/{{sample}}.rg.bam",
        bai=f"{DATA}/aligned/{{sample}}.rg.bam.bai"
    log:
        f"{DATA}/logs/fix_readgroups/{{sample}}.log"
    conda:
        "../envs/gatk.yaml"
    shell:
        """
        # Step 1: index input BAM (IMPORTANT)
        samtools index {input.bam}

        # Step 2: add read groups
        gatk --java-options "-Xmx8G" AddOrReplaceReadGroups \
            -I {input.bam} \
            -O {output.bam} \
            -RGID {wildcards.sample} \
            -RGLB lib1 \
            -RGPL ILLUMINA \
            -RGPU unit1 \
            -RGSM {wildcards.sample}

        # Step 3: index output BAM
        samtools index {output.bam}
        """
