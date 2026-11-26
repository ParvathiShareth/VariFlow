rule fastqc_trim_se:
    input:
        f"{DATA}/trimmed/{{sample}}.fastq.gz"
    output:
        html=f"{DATA}/fastqc_trimmed/{{sample}}_fastqc.html",
        zip=f"{DATA}/fastqc_trimmed/{{sample}}_fastqc.zip"
    log:
        f"{DATA}/logs/fastqc_trim_se/{{sample}}.log"
    wildcard_constraints:
        sample=SE
    threads: 2
    shell:
        """
        mkdir -p {DATA}/fastqc_trimmed
        mkdir -p {DATA}/logs/fastqc_trim_se
        fastqc {input} \
            -o {DATA}/fastqc_trimmed \
            -t {threads} \
            > {log} 2>&1
        """
rule fastqc_trim_pe:
    input:
        r1=f"{DATA}/trimmed/{{sample}}_R1.fastq.gz",
        r2=f"{DATA}/trimmed/{{sample}}_R2.fastq.gz"
    output:
        r1_html=f"{DATA}/fastqc_trimmed/{{sample}}_R1_fastqc.html",
        r1_zip=f"{DATA}/fastqc_trimmed/{{sample}}_R1_fastqc.zip",
        r2_html=f"{DATA}/fastqc_trimmed/{{sample}}_R2_fastqc.html",
        r2_zip=f"{DATA}/fastqc_trimmed/{{sample}}_R2_fastqc.zip"
    log:
        f"{DATA}/logs/fastqc_trim_pe/{{sample}}.log"
    wildcard_constraints:
        sample=PE
    threads: 2
    shell:
        """
        mkdir -p {DATA}/fastqc_trimmed
        mkdir -p {DATA}/logs/fastqc_trim_pe
        fastqc {input.r1} {input.r2} \
            -o {DATA}/fastqc_trimmed \
            -t {threads} \
            > {log} 2>&1
        """
rule multiqc_trimmed:
    input:
        expand(f"{DATA}/fastqc_trimmed/{{sample}}_fastqc.zip", sample=SE_SAMPLES),
        expand(f"{DATA}/fastqc_trimmed/{{sample}}_R1_fastqc.zip", sample=PE_SAMPLES),
        expand(f"{DATA}/fastqc_trimmed/{{sample}}_R2_fastqc.zip", sample=PE_SAMPLES)
    output:
        report=f"{DATA}/multiqc_trimmed/multiqc_report.html"
    log:
        f"{DATA}/logs/multiqc_trimmed/multiqc_trimmed.log"
    shell:
        """
        mkdir -p {DATA}/multiqc_trimmed

        # remove old reports (IMPORTANT)
        rm -rf {DATA}/multiqc_trimmed/*

        multiqc {DATA}/fastqc_trimmed \
            -o {DATA}/multiqc_trimmed \
            -n multiqc_report.html \
            > {log} 2>&1
        """
