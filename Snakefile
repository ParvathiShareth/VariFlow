configfile: "config/config.yaml"
REF = config["reference"]
DATA = config["data_dir"]
SE_SAMPLES = config["se_samples"]
PE_SAMPLES = config["pe_samples"]
SAMPLES = SE_SAMPLES + PE_SAMPLES
#print("Samples:", SAMPLES)
rule all:
    input:
        expand(f"{DATA}/variants_r3/{{sample}}.g.vcf.gz", sample=SAMPLES),
        expand(f"{DATA}/variants_r3/{{sample}}.g.vcf.gz.tbi", sample=SAMPLES)
        #f"{DATA}/variants_r3/final_variants_3.vcf.gz"
        
include: "rules/download.smk"
include: "rules/fasterq.smk"
include: "rules/fastqc_se.smk"
include: "rules/fastqc_pe.smk"
include: "rules/multiqc.smk"
include: "rules/reference.smk"
include: "rules/align.smk"
include: "rules/dedup.smk"
include: "rules/rg.smk"
include: "rules/gvcf_r1.smk"
include: "rules/bqsr.smk"
include: "rules/gvcf_r2.smk"
include: "rules/bqsr2.smk"
include: "rules/gvcf_r3.smk"

