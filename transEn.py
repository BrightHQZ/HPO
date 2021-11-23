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

    if (inFile == "" and (os.path.exists(inFile) or os.path.exists(os.getcwd() + "/" +  inFile))):
        print("Error: Must set the inFile !")
        sys.exit(2);
    if (outFile == "" and (os.path.exists(outFile) or os.path.exists(os.getcwd() + "/" +  outFile))):
        print("Error: Must set the outFile !")
        sys.exit(2);
    if (colN < 1):
        print("Error: The col number for translate must be provided !")
        sys.exit(2);

    if (os.path.exists(inFile) == False):
        inFile = os.getcwd() + "/" +  inFile;
    if (os.path.exists(outFile) == False):
        outFile = os.getcwd() + "/" +  outFile;

    with open(inFile, 'r') as f:
        w = open(outFile, 'w');
        while (f):
            line = f.readline().strip();
            if (len(line) > 1):
                in_text = line.replace("\n","").split("\t");
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
                    in_text.append(res);
                    w.write("\t".join(in_text) + "\n");
            else:
                break;
        w.close(); 

    print("Translation fished and the results were written into " + outFile);

if __name__ == "__main__":
    main(sys.argv[1:])
