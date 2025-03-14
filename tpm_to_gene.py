#!/bin/env python3

import pandas as pd
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-i', '--input-file', help='Input file containing TPM per transcript')
parser.add_argument('-a', '--annotation', help='Annotation file in gtf')
parser.add_argument('-o', '--output-file', help='Output file')
args = parser.parse_args()



# Caricare TPM di Salmon
tpm = pd.read_csv(args.input_file, sep="\t")
tpm['Name'] = tpm.Name.str.split('|').str[0]
# Caricare la mappa trascritto-gene
mapping = pd.read_csv(args.annotation, sep=" ", names=["gene", "transcript"])

# Unire le informazioni
tpm = tpm.merge(mapping, left_on="Name", right_on="transcript")

# Aggregare TPM per gene (somma dei trascritti associati)
gene_tpm = tpm.groupby("gene")["TPM"].sum().reset_index()

# Salvare i risultati
gene_tpm.to_csv(args.output_file, sep="\t", index=False)