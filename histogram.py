import matplotlib.pyplot as plt
import pandas as pd
import os

colnames=['Barcode', 'Percentage_of_Mouse_Gene'] 
exp_list = ['exp1', 'exp2', 'exp3', 'exp4', 'exp5.1', 'exp5.2', 'exp5.3', 'exp5.4', 'exp5.5']
for f in exp_list:
  input_filepath = './'+f+'/'+f+'_percent_mouse_genes_per_barcode.csv'
  output_filepath = './'+f+'/'+f 
  df = pd.read_csv(input_filepath)
  # print(df['Percent_expressed_genes_are_mouse_genes'].tolist()[0])
  plt.style.use('ggplot')
  histogram = plt.figure(figsize=(30,9))
  n, bins, patch = plt.hist(df['Percent_expressed_genes_are_mouse_genes'].tolist(), bins=100, color=['orange'],range=[-0.5,100.5],edgecolor='black')
  plt.legend(["Mouse"])
  plt.title("Percentage of Mouse Genes Per Barcode Histogram")
  plt.xlabel("% of Mouse Genes")
  plt.ylabel("Frequency")
  plt.xticks(range(0, 101))
  histogram.savefig(output_filepath+"_histogram.pdf", bbox_inches='tight')
