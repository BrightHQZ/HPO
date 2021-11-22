# HPO
    The project created for get HPO information and translated them from english to Chinese. In this script, the core tool is the AI cloud of YouDao to translation english to Chinese. So to application a account in YouDao AI cloud is necessary.  The url of AI cloud of YouDao is https://ai.youdao.com/#/

# Run command
    Rscript combinHPO.R -d rootDir -i appID -k appKey
    rootDir: Absolute path of target dir.
    appID, appKey: They are two string and obtained from AI cloud of YouDao after application translation servers.

# Depend patch
    The R package of "optparse" and "ontologyIndex" were need. Using the command of "install.packages(c("optparse","ontologyIndex"))" to install in R.


 
