import argparse
import csv
import os
from pathlib import Path
from urllib.parse import urljoin
from rdflib import Graph, Literal, RDF, DCTERMS, XSD, Namespace, BNode, URIRef

parser = argparse.ArgumentParser(
    description="Convert a CSV file with demographic data to an RDF cube.")
parser.add_argument('--source',
                    help="Path to the input CSV file.",
                    type=Path,
                    )
parser.add_argument('--output',
                    help="Path to the Turtle output file",
                    type=Path,
                    )
args = parser.parse_args()

base = "https://berlinonline.github.io/lod-berlin-einwohner/"
cube = Namespace("https://cube.link/")
schema = Namespace("https://schema.org/")
lor19 = Namespace("https://berlinonline.github.io/lod-berlin-lor-2019/")
unit = Namespace("https://berlinonline.github.io/lod-berlin-lor/vocab/")
einwohner = Namespace(base)
demvoc = Namespace(urljoin(base, "vocab/"))

graph = Graph()
graph_common = Graph()
stem = args.output.stem
common_file_name = args.output.with_stem(f"{stem}_common")
graphs = {
    args.output: graph,
    common_file_name: graph_common    
}

cube_id = 'c_einwohner'
cube_res = einwohner[cube_id]
graph_common.add( (cube_res, RDF.type, cube['Cube']) )
graph_common.add( (cube_res, schema['name'], Literal("RDF Data Cube mit demografischen Daten für Berlin", lang="de")) )
graph_common.add( (cube_res, schema['name'], Literal("RDF Data Cube containing demographic data for Berlin", lang="en")) )
graph_common.add( (cube_res, schema['description'], Literal("Der Cube entält demografische Daten, die aus CSV-Quellen erzeugt wurden. Jede Observation hat eine Zeit- und eine Raum-Dimension, Gesamteinwohnerzahl, geschlechterbasierte Kohorten und altersbasierte Kohorten. Es gibt ein Observationset pro Quell-Datei (eine Quelldatei pro Jahr) sowie ein Gesamt-Observationset.", lang="de")) )
graph_common.add( (cube_res, schema['description'], Literal("The cube contains demograohic data derived from source data in CSV format. The dimensions of each observation are date, location, total population, gender-based cohorts and various age-based cohorts. There is one Observationset per source CSV (one source file per year), and one overall Observationset.", lang="en")) )


overall_os_id = 'os_overall'
overall_os_res = einwohner[overall_os_id]
graph_common.add( (overall_os_res, RDF.type, cube['ObservationSet']) )
graph_common.add( (overall_os_res, schema['name'], Literal("Gesamt-ObservationSet", lang="de")) )
graph_common.add( (overall_os_res, schema['name'], Literal("Overall ObservationSet", lang="en")) )
graph_common.add( (overall_os_res, schema['description'], Literal("Das Gesamt-ObservationSet enthält die Observations aus allen CSV-Quellen / Jahren.", lang="de")) )
graph_common.add( (overall_os_res, schema['description'], Literal("The overall ObservationSet contains Observation from all CSV sources / years.", lang="en")) )
graph_common.add( (cube_res, cube['observationSet'], overall_os_res) )

source_file_path = args.source
source_file_name = source_file_path.parts[-1].split(".")[0]
current_os_id = f'os_{source_file_name}'
current_os_res = einwohner[current_os_id]
graph.add( (current_os_res, RDF.type, cube['ObservationSet']) )
graph.add( (current_os_res, schema['name'], Literal(f"ObservationSet für {source_file_name}", lang="de")) )
graph.add( (current_os_res, schema['name'], Literal(f"ObservationSet for {source_file_name}", lang="en")) )
graph.add( (current_os_res, schema['description'], Literal(f"Dieses ObservationSet enthält die Observations aus der CSV-Quelle {source_file_name}.", lang="de")) )
graph.add( (current_os_res, schema['description'], Literal(f"This ObservationSet contains Observations derived from the CSV source {source_file_name}.", lang="en")) )
graph_common.add( (cube_res, cube['observationSet'], current_os_res) )


IGNORE = [ 'ZEIT', 'RAUMID', 'BEZ', 'PGR', 'BZR', 'PLR', 'STADTRAUM' ]
city_region_mapping = {
    '1': demvoc['inner_city'],
    '2': demvoc['outer_city'],
    '9': demvoc['undefined_region'],
}

variable_mapping = {}
with open('data/temp/variable_property_mapping.csv', 'r') as f:
    for row in csv.DictReader(f, skipinitialspace=True):
        variable_mapping[row['variable']] = row['property']

with open(args.source) as f:
    for row in csv.DictReader(f, skipinitialspace=True):
        date = row['ZEIT']
        if date == '':
            continue
        lor = row['RAUMID']
        obs_id = f'obs_{date}_{lor}'
        obs_res = einwohner[obs_id]
        graph.add( (obs_res, RDF.type, cube['Observation']) )

        iso_date_year = f'{date[0:4]}-{date[4:6]}'
        graph.add( (obs_res, DCTERMS.date, Literal(iso_date_year, datatype=XSD.gYearMonth)) )

        plr_id = f'plr_{lor}'
        plr_res = lor19[plr_id]
        graph.add( (obs_res, URIRef(variable_mapping['RAUMID']), plr_res) )

        stadtraum_id = row['STADTRAUM']
        region_res = city_region_mapping[stadtraum_id]
        graph.add( (obs_res, URIRef(variable_mapping['STADTRAUM']), region_res) )

        for key, value in row.items():
            if key in IGNORE:
                continue
            dim_property = URIRef(variable_mapping[key])
            graph.add( (obs_res, dim_property, Literal(value, datatype=XSD.integer)) )
        
        graph_common.add( (overall_os_res, cube['observation'], obs_res) )
        graph.add( (current_os_res, cube['observation'], obs_res) )

for filename, graph_obj in graphs.items():
    graph_obj.bind("lor19", lor19)
    graph_obj.bind("demvoc", demvoc)
    graph_obj.bind("einwohner", einwohner)
    graph_obj.bind("cube", cube)
    graph_obj.bind("schema", schema)
    graph_obj.bind("dcterms", DCTERMS)
    with open(filename, "w") as output_file:
        output_file.write(graph_obj.serialize(format="turtle"))

