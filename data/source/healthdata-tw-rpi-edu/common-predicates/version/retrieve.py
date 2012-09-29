#!/usr/bin/env python

from datetime import *
import csv, sys, urllib, os, collections

query = '''
PREFIX void:          <http://rdfs.org/ns/void#> 

select distinct ?g ?label where {
  graph ?gs {
    [] ?p [].
    ?p rdfs:label ?label.
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
        #for line in csv.reader(open("/Users/jpm78/Downloads/sparql (2).csv"),delimiter=","):
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
                    result.add("<"+i+"> <"+health+"sharesColumnNamesWith> <"+j+"> .")
    try:
        os.makedirs(str(date.today())+"/automatic")
    except:
        pass
    o = open(str(date.today())+"/automatic/common-predicates.ntp","w")
    for row in result:
        o.write(row+"\n")
    
if __name__=='__main__':
    retrieve()
