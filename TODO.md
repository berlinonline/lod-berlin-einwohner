# TODO

- [X] vocabulary description
- [X] template for vocabulary terms
    - [X] label, comment, altlabel
    - [X] rdfs:definedBy
    - [X] breadcrumb should be Datensatz > VOCAB > CURRENT_TERM
- [X] convert sources
- [ ] cube constraint
- [ ] explain data structure in README
- [X] add sources to README
- [X] templates for 
    - [X] Cube, 
    - [X] ObservationSet, 
    - [X] Observation
- [X] `lor19` namespace prefix does not show up in observations (instead empty prefix is shown)
- [X] get names of PLRs from LOR-19 dataset and merge with this data, to display name instead of URL in observation
- [X] sort Observations in ObservationSet
- [X] fix Georeferenz in Observation (currently points back to observation)
- [X] in EWR2014 the leading 0s in the RAUMIDs are missing
- [X] there is no download dump
- [ ] bring improvements to template back upstream

## Scalability Problem

Generating the static site from the complete data (RDF for all 11 datasets) with Jekyll-RDF is ridiculously slow (~45 minutes). Solution:

- Partition the data into one graph for each source dataset and one common graph (dataset resource, cube resource, overall observationset etc.). In the Makefile, these are the following targets:
    - data/temp/all_commons.ttl (need to add void.ttl, berlinonline.ttl, demovoc.ttl -> data/temp/base_data.nt)
    - data/temp/%.ttl (where % is the `EWR$(YEAR)12E`)
- Use Jekyll-RDF to generate partial sites for each graph.
    - We need a separate `_config.yml` for each graph.
    - The only difference is the `jekyll_rdf/path` parameter.
- Merge partial sites.