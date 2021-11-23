# HPO
    The project created for get HPO information and translated them from english to Chinese. 
    In this script, the core tool is the AI cloud of YouDao to translation english to Chinese. 
    So to application a account in YouDao AI cloud is necessary.  
    The url of AI cloud of YouDao is https://ai.youdao.com/#/

# Run
    Rscript combinHPO.R -d rootDir -i appID -k appKey -p xxxx -s T
    rootDir: Absolute path of target dir.
    appID, appKey: They are two string and obtained from AI cloud of YouDao after application translation servers.
    xxxx: This is a path which contain transEn.py
    -s: Skip download file if the value is "T". Default value is "F"  

# Dependence
    The R package of "optparse" and "ontologyIndex" were need. 
    Using the command of "install.packages(c("optparse","ontologyIndex"))" to install in R.


 
