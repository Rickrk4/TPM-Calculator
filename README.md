# TPM Calculation from FASTQ (Salmon-based)

This Bash script calculates Transcripts Per Million (TPM) from a **FASTQ** sequencing sample. The script can be used for both **single-end** and **paired-end** reads. It uses **Salmon** for transcript quantification and a **Python script** to aggregate TPM by gene.

## Requirements

1. **Salmon**: Must be installed and configured for transcript indexing.
2. **Python**: The Python script `tpm_to_gene.py` is used for aggregating TPM by gene.
3. **Input Files**:
   - **FASTQ** files of the sample (single-end or paired-end).
   - **GTF** annotation file (e.g., `gencode.v44.annotation.gtf`).
   - **FASTA** file of transcripts (e.g., `gencode.v44.transcripts.fa`).
4. **System tools**:
   - **awk**, **tr** for file preprocessing.

Annotiation and Transcript can be downloaded from any source (Gencode o Ensembl). This script was tested using Gencode files, they can be downloaded in this way:

```bash
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_44/gencode.v44.transcripts.fa.gz
gunzip gencode.v44.transcripts.fa.gz
```
```bash
wget ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_44/gencode.v44.annotations.fa.gz
gunzip gencode.v44.annotations.fa.gz

```

## Installation

1. Ensure that **Salmon** and **Python** are installed.
2. Download the required input files (FASTQ, GTF, FASTA of transcripts).
3. Clone this repository (or download the script).

```bash
git clone https://github.com/your-username/tpm-calculation.git
cd tpm-calculation
# TPM Calculation from FASTQ (Salmon-based)

This Bash script calculates Transcripts Per Million (TPM) from a **FASTQ** sequencing sample. The script can be used for both **single-end** and **paired-end** reads. It uses **Salmon** for transcript quantification and a **Python script** to aggregate TPM by gene.

## Requirements

1. **Salmon**: Must be installed and configured for transcript indexing.
2. **Python**: The Python script `tpm_to_gene.py` is used for aggregating TPM by gene. It must be placed in the same directory of this script.
3. **Input Files**:
   - **FASTQ** files of the sample (single-end or paired-end).
   - **GTF** annotation file (e.g., `gencode.v44.annotation.gtf`).
   - **FASTA** file of transcripts (e.g., `gencode.v44.transcripts.fa`).
4. **System tools**:
   - **awk**, **tr** for file preprocessing.

## Installation

1. Ensure that **Salmon** and **Python** are installed.
2. Download the required input files (FASTQ, GTF, FASTA of transcripts).
3. Clone this repository (or download the script).

```bash
git clone https://github.com/your-username/tpm-calculation.git
cd tpm-calculation
```

## Usage 
Run the script with the following parameters:
```bash
./calculate_tpm.sh -1 FILE_1 -2 FILE_2 -a ANNOTATION_FILE -t TRANSCRIPT_FILE -o OUTPUT_FOLDER -i INDEX_FOLDER -T THREADS -p PYTHON_SCRIPT
```
### Example usage:
#### Single-end:
```bash
./calculate_tpm.sh -1 sample_R1.fastq -a gencode.v44.annotation.gtf -t gencode.v44.transcripts.fa -o sample_quant -i salmon_index -T 8
```
#### Paired-end:
```bash
./calculate_tpm.sh -1 sample_R1.fastq -2 sample_R2.fastq -a gencode.v44.annotation.gtf -t gencode.
```

### Parameters
Parameters:
* -1 FILE_1 : FASTQ File 1 (mandatory for both single-end and paired-end).
* -2 FILE_2 : FASTQ File 2 (mandatory only for paired-end).
* -a|--annotation-file ANNOTATION_FILE : GTF annotation file (e.g., gencode.v44.annotation.gtf).
* -t|--transcript-file TRANSCRIPT_FILE : FASTA file of transcripts (e.g., gencode.v44.transcripts.fa).
* -o|--output-folder OUTPUT_FOLDER : Output folder for Salmon (default: sample_quant).
* -i|--index-folder INDEX_FOLDER : Folder where Salmon creates the indexes (default: salmon_index).
* -T|--threads THREADS : Number of threads to use for Salmon (default: 1).
* -p|--python-script PYTHON_SCRIPT : Python script for grouping TPM by gene (default: tpm_to_gene.py).
