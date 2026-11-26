DATA = config["data_dir"]

rule mark_duplicates:
    input:
        bam=f"{DATA}/aligned/{{sample}}.sorted.bam"
    output:
        bam=f"{DATA}/aligned/{{sample}}.markdup.bam",
        metrics=f"{DATA}/aligned/{{sample}}.metrics.txt"
    log:
        f"{DATA}/logs/mark_duplicates/{{sample}}.log"
    conda:
        "../envs/gatk.yaml"
    shell:
        """
        gatk MarkDuplicates \
        -I {input.bam} \
        -O {output.bam} \
        -M {output.metrics}
        """

rule index_dedup:
    input:
        bam=f"{DATA}/aligned/{{sample}}.markdup.bam"
    output:
        bai=f"{DATA}/aligned/{{sample}}.markdup.bam.bai"
    log:
        f"{DATA}/logs/index_dedup/{{sample}}.log"
    conda:
        "../envs/samtools.yaml"
    shell:
        """
        samtools index {input.bam}
        """
