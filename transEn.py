import os;
import getopt;
import sys;
import time;
import trans as translation;

def printHelpInfor():
    print("The style for execution as following: transEn -i xxxx.txt -c 2 -o xxxx.txt")
    print("-i : input file; -c the column number of text for translation; -o output file; ")


def main(argv):
    try:
        opts, args = getopt.getopt(argv, "hi:c:o:a:k:")
    except getopt.GetoptError as err:
        print(err)
        sys.exit(2)

    for opt, arg in opts:
        if opt == '-h':
            printHelpInfor()
            sys.exit(0)
        elif opt == '-i':
            inFile = arg
        elif opt == '-c':
            colN = int(arg)
        elif opt == '-o':
            outFile = arg
        elif opt == "-a":
            appid = arg
        elif opt == "-k":
            appkey = arg 

    if (inFile == "" or os.path.exists(inFile) == False):
        print("Error: Must set the inFile or file (" + inFile + ") is not exist!")
        sys.exit(2);
    if (outFile == ""):
        print("Error: Must set the outFile !")
        sys.exit(2);
    if (colN < 1):
        print("Error: The col number for translate must be provided !")
        sys.exit(2);

    with open(inFile, 'r') as f:
        i = 0;
        w = open(outFile, 'w');
        while (f):
            line = f.readline().strip().replace("\n","");
            in_text = line.split("\t");
            if (len(in_text) > 1):
                i = i + 1;
                res = translation.translate_text(in_text[colN - 1], appid, appkey);
                if (res == "e1"):
                    print("Error: Application id is null!");
                    break;
                elif (res == "e2"):
                    print("Error: Application key is null!");
                    break;
                elif (res == "e3"):
                    print("Error: Translation text is empty!");
                    continue;
                else:
                    while (res["errorCode"] != "0"):
                        if (res["errorCode"] == "412" or res["errorCode"] == "411"):
                            print("System reject servers for frequence request! sleep 100 seconds, now!")
                            time.sleep(100);
                        res = translation.translate_text(in_text[colN - 1], appid, appkey);
                    in_text.append(res["translation"][0]);
                    w.write(("\t".join(in_text) + "\n"));
                    time.sleep(0.2);
                    if (i % 200 == 0):
                        print(i);
            else:
                break;
        w.close(); 

    print("Translation fished and the results were written into " + outFile);

if __name__ == "__main__":
    main(sys.argv[1:])
