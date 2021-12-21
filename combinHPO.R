library(optparse)

helpF <- function() {
  print("The run command is: Rscript combinHPO -d xxx -i xxx -k xxx -p xxxx -s T");
  print("The parameter -d -i -k and -p were necessary!");
}
# 描述参数的解析方式
option_list <- list(
  make_option(c("-d", "--rootDir"), type = "character", default = "", 
  action = "store", help = "The root dir for execution the program!"),
  make_option(c("-i", "--appID"), type = "character", default = "", 
  action = "store", help = "The application id in YouDao AI cloud!"),
  make_option(c("-k", "--appKey"), type = "character", default = "", 
  action = "store", help = "The application key in YouDao AI cloud!"),
  make_option(c("-p", "--pythonP"), type = "character", default = "", 
  action = "store", help = "The dir of including transEn.py!"),
  make_option(c("-s", "--skipDownload"), type = "character", default = "F",
  action = "store", help = "The application key in YouDao AI cloud!")
  # make_option(c("-h", "--help"), type = "logical", default = FALSE,
  #             action = "store_TRUE", help = "This is Help!"
  # )
)

# 解析参数
opt = parse_args(OptionParser(option_list = option_list, usage = "This Script is a test for arguments!"))

if (opt$rootDir == "" || opt$appID == "" || opt$appKey == "" || opt$python == "") {
    helpF();
    quit()
}
opt$python <- paste(opt$python,"/transEn.py", sep = "");
if (!file.exists(opt$python)) {
  print(paste("The python script of transEn.py is not exists in ", opt$python, sep = ""));
  quit()
}

if (! dir.exists(opt$rootDir)) dir.create(opt$rootDir);

setwd(opt$rootDir)

if (opt$skipDownload == "F") {
  print("Download hp.obo from http://purl.obolibrary.org/obo/hp.obo.\n");
  system("wget http://purl.obolibrary.org/obo/hp.obo -O hp.obo");
  print("Download phenotype_to_genes.txt from http://purl.obolibrary.org/obo/hp/hpoa/phenotype_to_genes.txt.\n");
  system("wget http://purl.obolibrary.org/obo/hp/hpoa/phenotype_to_genes.txt -O phenotype_to_genes.txt");
  print("Download phenotype.hpoa from http://purl.obolibrary.org/obo/hp/hpoa/phenotype.hpoa.\n");
  system("wget http://purl.obolibrary.org/obo/hp/hpoa/phenotype.hpoa -O phenotype.hpoa");
}

if (!file.exists("hp.obo") || !file.exists("phenotype_to_genes.txt") || !file.exists("phenotype.hpoa") ||
    file.size("hp.obo") < 1 || file.size("phenotype_to_genes.txt") < 1 || file.size("phenotype.hpoa") < 1) {
  print("One or more of the files were not exist. Please check of the files of hp.obo, phenotype_to_genes.txt and phenotype.hpoa!");
  quit();
}


library(ontologyIndex)
hpo <- get_ontology("hp.obo", extract_tags = "everything")
hpoList <- data.frame(hpoID = hpo$id, hpoName = hpo$name)
write.table(hpoList, "hp.txt", sep = "\t", quote = F, row.names = F, col.names = F)
hpoList <- data.frame(hpoID = hpo$id, hpoComment = hpo$comment);
write.table(hpoList[!is.na(hpoList$hpoComment),], "hp_comment.txt", sep = "\t", quote = F, row.names = F, col.names = F)
hpoList <- data.frame(hpoID = hpo$id, hpoDef = hpo$def);
hpoList$hpoDef <- gsub("\"|\\[HPO:probinson\\]|\\[HPO:curators\\]","",hpoList$hpoDef)
write.table(hpoList[!is.na(hpoList$hpoDef),], "hp_def.txt", sep = "\t", quote = F, row.names = F, col.names = F)
print("hp.txt created ......")

disease <- read.delim2("phenotype.hpoa", comment.char = "#", header = F);
write.table(unique(disease[,1:2]), "unique_disease.txt", sep = "\t", quote = F, row.names = F, col.names = F);
print("unique_disease.txt created ......")

print("Translation hpo in English to Chinese.");
print(paste("python ", opt$python, " -i ", opt$rootDir,"/hp.txt -c 2 -o ", opt$rootDir, "/hp_T.txt -a ", opt$appID, " -k ", opt$appKey, sep = ""))
system(paste("python", opt$python, "-i hp.txt -c 2 -o hp_T.txt -a", opt$appID, "-k", opt$appKey, sep = " "));
print("Translation disease in English to Chinese.");
print(paste("python ", opt$python,  " -i ", opt$rootDir, "/unique_disease.txt -c 2 -o ", opt$rootDir, "/unique_disease_T.txt -a ", opt$appID, " -k ", opt$appKey, sep = ""));
system(paste("python ", opt$python,  " -i ", opt$rootDir, "/unique_disease.txt -c 2 -o ", opt$rootDir, "/unique_disease_T.txt -a ", opt$appID, " -k ", opt$appKey, sep = ""));
print("Preparing combine HPO information!")

disease_T <- read.delim2("unique_disease_T.txt", comment.char = "#", header = F);
p_g <- read.delim2("phenotype_to_genes.txt", comment.char = "#", header = F);
hpo_T <- read.delim2("hp_T.txt", comment.char = "#", header = F, quote = "");

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
combined$hpoOnsetName[is.na(combined$hpoFreqName)] <- ""
combined$hpoOnsetNameCN[is.na(combined$hpoOnsetNameCN)] <- ""
combined$hpoFreqName[is.na(combined$hpoFreqName)] <- ""
combined$hpoFreqCN[is.na(combined$hpoFreqCN)] <- ""
combined$hpoTargetName[is.na(combined$hpoTargetName)] <- ""
combined$hpoTargetNameCN[is.na(combined$hpoTargetNameCN)] <- ""

write.table(combined, "hpo_combined.txt", sep = "\t", quote = F, row.names = F)
print(paste("HPO information has been combined and saved at: ", opt$rootDir, "/hpo_combined.txt !", sep = ""));
