'''
Name: fe_netflow
Version: 0.2
Author: Tyron howard
Date: 5.6.2019
Desciption: This will take FireEye's "Related network Activity" JSON format and parse metadata for netflow.
Future Installments: TCP Flags, Total Duration Times, Match Ports against requests.
'''
import json
import datetime

fe_json = open('/home/ij-dev/Documents/fe_sample_json.txt', 'r')
json_data = fe_json.read()
fe_json.close()
json_parse = json_data.split('\n')

def sort_list(e):
        return e["Date"]

l = []
for i in json_parse:
    j = json.loads(i)
    l.append({
            "Date":  j["resolve"]["date"],
            "Change": j["resolve"]["change"],
            "Domain": j["resolve"]["domainName"],
            "IP": j["resolve"]["ip"][0]
            })

l.sort(key=sort_list)

for x in range(len(l)):
        print(l[x]["Date"] + " " + l[x]["Change"] + " " + l[x]["IP"] + " " + l[x]["Domain"])
