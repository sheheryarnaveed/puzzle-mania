#!/usr/bin/perl
use strict; use warnings;

my $MIN_COUNT = 1;

die"
Usage: output_percent_mouse_genes_per_barcode.pl <Path/to/gencode.vM24.unique_gene_names.gtf> <Path/to/gencode.v33.unique_gene_names.gtf>
" unless @ARGV==2;

my ($mouse_gtf, $human_gtf) = ($ARGV[0], $ARGV[1]);

if ($mouse_gtf !~ /.*gencode.vM24.unique_gene_names.gtf/) {
	die "mouse gtf isn't gencode.vM24.unique_gene_names.gtf\n";
} elsif ($human_gtf !~ /.*gencode.v33.unique_gene_names.gtf/) {
	die "human gtf isn't gencode.v33.unique_gene_names.gtf\n";
}

my %all_genes;
#get whole set of mouse genes and human genes
for my $species (qw(mouse human)) {
	my $IN;
	if ($species eq "mouse") {
		open $IN, "<$mouse_gtf" or die "can't open $mouse_gtf\n";
	} elsif ($species eq "human") {
		open $IN, "<$human_gtf" or die "can't open $human_gtf\n";
	}
	while (<$IN>) {
		if ($_ =~ /^#/) {
			next;
		}
	
		my $gene_name;
		if ($_ =~ /gene_name \"(.*?)\"/) {
			$gene_name = $1;
		}
		$all_genes{$species}{$gene_name}++;
	}
	
	close $IN;
	
}

for my $exp (qw(1 2 3 4 5.1 5.2 5.3 5.4 5.5)) {
	my $exp_matrix = "exp$exp/exp$exp.csv";
	my $output_file = "exp$exp/exp$exp" . "_percent_mouse_genes_per_barcode.csv";
	
	open my $IN, "<$exp_matrix" or die "can't open $exp_matrix\n";
	my $header = <$IN>;
	my @header_ar = split(",", $header);
	chomp(@header_ar);
	
	my %count_expressed_barcodes;
	
	while (<$IN>) {
		chomp;
		my @line = split(",", $_);
		my $gene = $line[0];
		for (my $i=1; $i < @line; $i++) {
			if ($line[$i] >= $MIN_COUNT) {
				for my $species (qw(mouse human)) {
					if (exists $all_genes{$species}{$gene}) {
						$count_expressed_barcodes{$header_ar[$i]}{$species}++;
					}
				}
			}
		}
	}
	close $IN;
	
	open my $OUT, ">$output_file" or die "can't open $output_file\n";
	print $OUT "Barcode,Percent_expressed_genes_are_mouse_genes\n";
	for my $barcode (keys %count_expressed_barcodes) {
		for my $species (qw(mouse human)) {
			if (!exists $count_expressed_barcodes{$barcode}{$species}) {
				$count_expressed_barcodes{$barcode}{$species} = 0;
			}
		}
		
		my $tot_genes;
		for my $species (qw(mouse human)) {
			$tot_genes += $count_expressed_barcodes{$barcode}{$species};
		}
		
		my $mouse_genes_pct = ($count_expressed_barcodes{$barcode}{"mouse"} / $tot_genes) * 100;
		
		print $OUT $barcode . "," . $mouse_genes_pct . "\n";
	}
	
	close $OUT;

}
