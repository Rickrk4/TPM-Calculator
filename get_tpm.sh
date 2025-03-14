#!/bin/bash

#FILE_1="sample_R1.fastq" #File 1.
#FILE_2="sample_R2.fastq" #File 2. Only with paired-end
#ANNOTATION_FILE="gencode.v44.annotation.gtf" #Annotation file
#TRANSCRIPT_FILE="gencode.v44.transcripts.fa" #Transcripts file
OUTPUT_FOLDER="sample_quant" #Output folder. 
INDEX_FOLDER="salmon_index" #Index folder in which samlmon will create his indexes.
THREADS=1
SALMON_TYPE="quasi" #"full"
PYTHON_SCRIPT="tpm_to_gene.py"

exit_abnormal_code() {
  echo "$1" 1>&2
  exit "$2"
}

# Funzione di help
usage() {
  echo "Questo script calcola le TPM partenda da un sample in FASTQ. Può essere sia single-end che paired-end."
  echo "Lo script è stato testato usando references di Gencode e dati ottenuti da ncbi tramite sra-toolkit." 
  echo "Uso: $0 -1 FILE_1 -2 FILE_2 -a ANNOTATION_FILE -t TRANSCRIPT_FILE -o OUTPUT_FOLDER -i INDEX_FOLDER"
  echo "  -1 FILE_1            : File FASTQ 1 (Mandatory)"
  echo "  -2 FILE_2            : File FASTQ 2 (Mandatory only if your reads are paired-end)"
  echo "  -a|--annotation-file ANNOTATION_FILE : File di annotazione GTF"
  echo "  -t|--transcript-file TRANSCRIPT_FILE : File FASTA dei trascritti"
  echo "  -o|--output-folder   : Cartella di output per Salmon. Optional (default sample_quant)."
  echo "  -i|--index-folder    : Cartella degli indici di Salmon. Optional (default sample_index)."
  echo "  -T|--threads         : Numero di threads da utilizzare per salmon (Default 1)"
  echo "  -p|--python-script   : Path dello script in python per ragruppare le TPM per gene (default ./tpm_to_gene.py)"
  exit 1
}

# Parsing dei parametri da linea di comando
while [[ $# -gt 0 ]]; do
  case "$1" in
    -1) FILE_1="$2"; shift 2;;
    -2) FILE_2="$2"; shift 2;;
    -a|--annotation-file) ANNOTATION_FILE="$2"; shift 2;;
    -t|--transcript-file) TRANSCRIPT_FILE="$2"; shift 2;;
    -o|--output-folder) OUTPUT_FOLDER="$2"; shift 2;;
    -i|--index-folder) INDEX_FOLDER="$2"; shift 2;;
    -p|--python-script) PYTHON_SCRIPT="$2"; shift 2;;
    -T|--threads) THREADS="$2"; shift 2;;
    *) usage;;
  esac
done


# Verifica che i file di input esistano
if [[ ! -f "$FILE_1" ]]; then
  echo "Errore: il file $FILE_1 non esiste!"
  exit 1
fi

if [ ! -f "$ANNOTATION_FILE" ] && { [ ! -d "$INDEX_FOLDER" ] || [ -z "$(ls -A "$INDEX_FOLDER")" ]; }; then
  echo "Errore: il file di annotazione $ANNOTATION_FILE non esiste!"
  exit 1
fi

if [ ! -f "$TRANSCRIPT_FILE" ] && { [ ! -d "$INDEX_FOLDER" ] || [ -z "$(ls -A "$INDEX_FOLDER")" ]; }; then
  echo "Errore: il file dei trascritti $TRANSCRIPT_FILE non esiste!"
  exit 1
fi

## Start
if [ ! -d "$INDEX_FOLDER" ] ||  [ -z "$(ls -A "$INDEX_FOLDER")" ]; then
    echo "Making indexes"
    salmon index -t gencode.v44.transcripts.fa -i "$INDEX_FOLDER" --type "$SALMON_TYPE" -k 31 || exit_abnormal_code "Unable to make salmon index" 2
    awk '$3 == "transcript" {print $10, $12}' gencode.v44.annotation.gtf | tr -d '";' > "$INDEX_FOLDER/transcript_to_gene.tsv" || exit_abnormal_code "Unable to make transcript_gene file" 4
fi

## Take TPM per transcript
if [[ -f "$FILE_2" ]]; then
  salmon quant -p "$THREADS" -i "$INDEX_FOLDER" -l A -1 "$FILE_1" -2 "$FILE_2" -o "$OUTPUT_FOLDER" || exit_abnormal_code "Unable to quantify tpm" 3
else
  salmon quant -p "$THREADS" -i "$INDEX_FOLDER" -l A -r "$FILE_1" -o "$OUTPUT_FOLDER" || exit_abnormal_code "Unable to quantify tpm" 3
fi

## Group TPM by gene
python tpm_to_gene.py -i "$OUTPUT_FOLDER/quant.sf" -a "$INDEX_FOLDER/transcript_to_gene.tsv" -o "$OUTPUT_FOLDER/TPM_per_gene.tsv" || exit_abnormal_code "Unable to convert tpm per transcript into tpm per gene" 5
