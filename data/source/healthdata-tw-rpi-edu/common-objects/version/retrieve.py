#!/usr/bin/env python

from datetime import *
import csv, sys, urllib, os, collections

query = '''
PREFIX void:          <http://rdfs.org/ns/void#> 

select distinct ?g ?o where {
graph ?gs {
  ?s ?p ?o.
  ?p rdfs:label ?label.
  filter(isLiteral(?o) && strlen(str(?o)) > 2 && ! REGEX (?o, "^[ 0-9\\\\._/\\\\-]+$"))
}

?g void:subset ?gs.

?g a void:Dataset.
}
'''
endpointPrefix = "http://healthdata.tw.rpi.edu/sparql?&format=text%2Fcsv&timeout=0&debug=on&"
datasetURL = endpointPrefix+urllib.urlencode([("query",query)])

health = 'http://purl.org/twc/health/vocab/'

def retrieve():
    graph = collections.defaultdict(list)
    m = None
    for line in csv.reader(urllib.urlopen(datasetURL),delimiter=","):
        #for line in csv.reader(open("/Users/jpm78/Downloads/twc-healthdata-literals (1).csv"),delimiter=","):
        if m == None:
            m = [(line[i],i) for i in range(len(line))]
            continue
        graph[line[1]].append(line[0])
    result = set()
    for literal in graph.keys():
        graphs = graph[literal]
        for i in graphs:
            for j in graphs:
                if i != j:
                    result.add("<"+i+"> <"+health+"sharesCellValuesWith> <"+j+"> .")
    try:
        os.makedirs(str(date.today())+"/automatic")
    except:
        pass
    o = open(str(date.today())+"/automatic/common-objects.ntp","w")
    for row in result:
        o.write(row+"\n")
    
if __name__=='__main__':
    retrieve()
