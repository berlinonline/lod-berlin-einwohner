# TODO

- [X] vocabulary description
- [ ] template for vocabulary terms
    - [ ] label, comment, altlabel
    - [ ] rdfs:definedBy
    - [ ] breadcrumb should be Datensatz > VOCAB > CURRENT_TERM
- [X] convert sources
- [ ] cube constraint
- [ ] explain data structure in README
- [X] add sources to README
- [X] templates for 
    - [X] Cube, 
    - [X] ObservationSet, 
    - [X] Observation
- [ ] `lor19` namespace prefix does not show up in observations (instead empty prefix is shown)
- [ ] get names of PLRs from LOR-19 dataset and merge with this data, to display name instead of URL in observation

## Scalability Problem

Generating the static site from the complete data (RDF for all 11 datasets) with Jekyll-RDF is ridiculously slow (~45 minutes). Solution:

- Partition the data into one graph for each source dataset and one common graph (dataset resource, cube resource, overall observationset etc.). In the Makefile, these are the following targets:
    - data/temp/all_commons.ttl (need to add void.ttl, berlinonline.ttl, demovoc.ttl -> data/temp/base_data.nt)
    - data/temp/%.ttl (where % is the `EWR$(YEAR)12E`)
- Use Jekyll-RDF to generate partial sites for each graph.
    - We need a separate `_config.yml` for each graph.
    - The only difference is the `jekyll_rdf/path` parameter.
- Merge partial sites.