import requests
import time
import hashlib
import uuid

youdao_url = 'https://openapi.youdao.com/api'

def translate_text (translate_text = "", id = "", key = "", des = "es", src = "zh-CHS"):
    if (id == ""):
        return "e1"
    if (key == ""):
        return "e2"
    if (translate_text == ""): 
        return "e3";
    elif (len(translate_text) <= 20):
        input_text = translate_text
    elif (len(translate_text) > 20):
        input_text = translate_text[:10] + str(len(translate_text)) + translate_text[-10:]
    
    time_curtime = int(time.time())
    app_id = id
    uu_id = uuid.uuid4()
    app_key = key

    sign = hashlib.sha256((app_id + input_text + str(uu_id) + str(time_curtime) + app_key).encode('utf-8')).hexdigest()

    data = {
        'q':translate_text,
        'from':"en",
        'to':"zh-CHS",
        'appKey':app_id,
        'salt':uu_id,
        'sign':sign,
        'signType':"v3",
        'curtime':time_curtime,
    }

    r = requests.get(youdao_url, params = data).json()
    return(r["translation"][0])
