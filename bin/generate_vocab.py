import csv
from rdflib import Graph, Literal, RDF, RDFS, DCTERMS, SKOS, XSD, Namespace, BNode

base = "https://berlinonline.github.io/lod-berlin-einwohner/vocab/"
graph = Graph()
schema = Namespace("https://schema.org/")
geo = Namespace("http://www.opengis.net/ont/geosparql#")
einwohner = Namespace(base)

with open('csv_schema.csv') as f:
    schema = [{key: value for key, value in row.items()}
        for row in csv.DictReader(f, skipinitialspace=True)]

for entry in schema:
    property_id = entry['label'].lower()
    property_res = einwohner[property_id]
    graph.add( (property_res, RDF.type, RDF.Property) )
    graph.add( (property_res, RDFS.label, Literal(entry['label'], "de")) )
    graph.add( (property_res, RDFS.comment, Literal(entry['description'], "de")) )

    if entry['alt_label']:
        graph.add( (property_res, SKOS.altLabel, Literal(entry['alt_label'], "de")) )
    
    if entry['value_type'] == "GZ":
        graph.add( (property_res, RDFS.range, XSD.integer) )

graph.bind("einwohner", einwohner)
graph.bind("skos", SKOS)

with open("vocab.ttl", "w") as output_file:
    output_file.write(graph.serialize(format="turtle"))
