DATA = config["data_dir"]

FASTQC_DIR = f"{DATA}/fastqc"
SE = "|".join(config["se_samples"])

rule fastqc_se:
    input:
        f"{DATA}/fastq/{{sample}}.fastq.gz"
    output:
        html=f"{FASTQC_DIR}/{{sample}}_fastqc.html",
        zip=f"{FASTQC_DIR}/{{sample}}_fastqc.zip"
    threads: 4
    wildcard_constraints:
        sample=SE
    log:
        f"{DATA}/logs/fastqc/{{sample}}.log"
    shell:
        """
        mkdir -p outputs/fastqc
        export _JAVA_OPTIONS="-Xmx4g"
        fastqc -t {threads} {input} --outdir outputs/fastqc
        """
