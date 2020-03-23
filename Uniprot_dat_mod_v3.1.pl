#!/Users/walter/miniconda2/bin/perl

use Array::Utils qw(:all);  ## loading this utility to be albe to compare different arrays
use Term::ProgressBar;

if ((!$ARGV[0]) && (!$ARGV[1])){   #reading imput file with list of Name descriptors to look for in the ID line of hte .dat file
print "Please introduce your imput file .dat : \n";
$file=<STDIN>;         #This is in case the input is not in the argument, we demand the name of the file             
chomp $file;
print "Now please introduce your imput file .txt with the list of genes you want to extract from the originatl .dat file : \n";
$list=<STDIN>;         #This is in case the input is not in the argument, we demand the name of the file             
chomp $list;
}else{
$file=$ARGV[0]; #When the files are given by arguments (perl program.pl file.fasta list.txt)
$list=$ARGV[1];
chomp $file;
chomp $list;
}
($name,$extension)=split(/\./,$file);   #Once we have $file from any of the ways, we remove the extension to create the output only with one extension

$tot_genes = `grep -c "//" < $file`;

open(input,$file);
open(list,$list);
open(output, ">$name"."_subset.dat");
open(output2, ">Genes_type_not_found.txt");
open(log_file, ">log_file.txt");  ## this log file is to be sure that, in case the computer turn off unexpectedly, if this log file is written menas that the scirpt finished in time

open my $handle, '<', $list;         ## storing the list of genes we want to look for in a single array from the imput file
chomp(my @genes = <$handle>);  ## Creating an array with all the genes names that are in the list input file
close $handle;

my @database;  ## creating an empty database where each line of the .dat input file will be sotred
my @gene_not_found;
my @gene_found;

$end_line = '//';
$mark=0;      #I put a mark to know how many lines I went through
$mark1=0;   ## this mark will be used to count how many genes the script managed to extract
print "Your script is running correctly. This will take a while\n";
print "Total numnber of genes to examine is $tot_genes\n";
while (<input>){
  chomp $_;#Remember, always you take information from a file or from the prompt to remove the "Enter"
  push @database, $_; ## push the line in array
  if (($_ =~ /^ID/) || ($_ =~ /^GN/) || ($_ =~ /GO;/)){
    push @database_subset, $_;
    }
    if ($_ =~ /^$end_line/){  ##If the line starts with //,
      $mark++;
      $perc=$mark*100/$tot_genes;
      print "$perc% of the total genes examinde\n"; 
    foreach $i(@genes){
      if (grep(/$i/i, @database_subset)){
        $mark1++;  ## marking +1 for each gene matched
        push @gene_found, $i;
        @database_subset=();
          foreach $d(@database){
            print output "$d\n";
          }
      }else{
            push @gene_not_found, $i;
      }
    }
  @database=();  ## empty the database
  }
}  
my @minus = array_minus( @gene_not_found, @gene_found);
my @minus_unique =   unique(@minus);
foreach $m(@minus_unique){
  print output2 "$m\n";
}
print "The script identified $mark1 genes matching with your input list.\nYour script run correctly.\n";
close (input,list,output,output2);
print log_file "The script identified $mark1 genes matching with your input list.\nYour script run correctly till the end.\n";
close (log_file);
