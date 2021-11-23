library(optparse)

helpF <- function() {
  print("The run command is: Rscript combinHPO -d xxx -i xxx -k xxx")
}
# 描述参数的解析方式
option_list <- list(
  make_option(c("-d", "--rootDir"), type = "character", default = "", action = "store", help = "The root dir for execution the program!"),
  make_option(c("-i", "--appID"), type = "character", default = "", action = "store", help = "The application id in YouDao AI cloud!"),
  make_option(c("-k", "--appKey"), type = "character", default = "", action = "store", help = "The application key in YouDao AI cloud!")
  # make_option(c("-h", "--help"), type = "logical", default = FALSE,
  #             action = "store_TRUE", help = "This is Help!"
  # )
)

# 解析参数
opt = parse_args(OptionParser(option_list = option_list, usage = "This Script is a test for arguments!"))

if (opt$rootDir == "" || opt$appID == "" || opt$appKey == "") {
    print("The parameter -d -i and -k were necessary!");
    helpF();
    quit()
}

if (! dir.exists(opt$rootDir)) dir.create(opt$rootDir);

setwd(opt$rootDir)

print("Download hp.obo from http://purl.obolibrary.org/obo/hp.obo.\n");
system("wget http://purl.obolibrary.org/obo/hp.obo -O hp.obo");
print("Download phenotype_to_genes.txt from http://purl.obolibrary.org/obo/hp/hpoa/phenotype_to_genes.txt.\n");
system("wget http://purl.obolibrary.org/obo/hp/hpoa/phenotype_to_genes.txt -O phenotype_to_genes.txt");
print("Download phenotype.hpoa from http://purl.obolibrary.org/obo/hp/hpoa/phenotype.hpoa.\n");
system("wget http://purl.obolibrary.org/obo/hp/hpoa/phenotype.hpoa -O phenotype.hpoa");

if (!file.exists("hp.obo") || !file.exists("phenotype_to_genes.txt") || !file.exists("phenotype.hpoa") ||
    file.size("hp.obo") < 1 || file.size("phenotype_to_genes.txt") < 1 || file.size("phenotype.hpoa") < 1) {
  print("One or more of the files were not exist. Please check of the files of hp.obo, phenotype_to_genes.txt and phenotype.hpoa!");
  quit();
}


library(ontologyIndex)
hpo <- get_ontology("hp.obo")
hpoList <- data.frame(hpoID = hpo$id, hpoName = hpo$name)
write.table(hpoList, "hp.txt", sep = "\t", quote = F, row.names = F, col.names = F)

disease <- read.delim2("phenotype.hpoa", comment.char = "#", header = F);
write.table(unique(disease[,1:2]), "unique_disease.txt", sep = "\t", quote = F, row.names = F, col.names = F);

print("Translation hpo in English to Chinese.\n");
system("python TransEn.py -i hpo.txt -c 2 -o hpo_T.txt")
print("Translation disease in English to Chinese.\n");
system("python TransEn.py -i unique_disease.txt -c 2 -o unique_disease_T.txt")

disease_T <- read.delim2("unique_disease_T.txt", comment.char = "#", header = F);
p_g <- read.delim2("phenotype_to_genes.txt", comment.char = "#", header = F);
hpo_T <- read.delim2("hpo_T.txt", comment.char = "#", header = F, quote = "");

combined <- merge(disease, hpo_T, by.x = "V7", by.y = "V1", all.x = T);
combined <- merge(combined, hpo_T, by.x = "V8", by.y = "V1", all.x = T);
combined <- merge(combined, hpo_T, by.x = "V10", by.y = "V1", all.x = T);
combined <- merge(combined, hpo_T, by.x = "V4", by.y = "V1", all.x = T);
combined <- merge(combined, disease_T[,c(1,3)], by.x = "V1", by.y = "V1", all.x = T);
combined <- merge(combined, p_g[,c(7,1,4)], by.x = c("V1","V4"), by.y = c("V7","V1"));
combined <- combined[,c(1,6,21,22,2,19,20,5,13,14,4,15,16,3,17,18,8:11,7)]
colnames(combined) <- c("diseaseID","diseaseName","diseaseNameCN","gene","hpoID","hpoName","hpoNameCN","hpoOnsetID",
"hpoOnsetName","hpoOnsetNameCN","hpoFreqID","hpoFreqName","hpoFreqCN","hpoTargetID","hpoTargetName","hpoTargetNameCN",
"ref","evidenceCode","sex","subOntology","Qualifier")

write.table(combined, "hpo_combined.tab", sep = "\t", quote = F, row.names = F)
