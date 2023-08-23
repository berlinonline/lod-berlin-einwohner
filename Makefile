base_uri = https://berlinonline.github.io/lod-berlin-einwohner/
berlinonline_url = https://raw.githubusercontent.com/berlinonline/lod-berlin-bo/main/data/static/berlinonline.ttl
datenregister_dump = data/static/datenregister.berlin.de.20230711.json

data/temp/void.nt: data/temp
	@echo "converting void.ttl to $@ ..."
	@rdfpipe -o ntriples void.ttl > $@

data/temp/berlinonline.ttl: data/temp
	@echo "downloading $(berlinonline_url)..."
	@curl -s -o $@ "$(berlinonline_url)"

data/temp/datasetlist.json: data/temp
	@cat $(datenregister_dump) | jq '[.datasets[] | select(.title | startswith("Einwohnerinnen und Einwohner in Berlin in LOR-Planungsräumen am")) | { title: .title, name: .name, csv: .resources[] | select(.format == "CSV") | .url, pdf: .resources[] | select(.format == "PDF") | .url } ]' > $@

data/temp/datasetlist.csv: data/temp/datasetlist.json
	@cat $< | jq -r '(map(keys) | add | unique) as $$cols | map(. as $$row | $$cols | map($$row[.])) as $$rows | $$cols, $$rows[] | @csv' | csvcut -d "," -c "name,title,csv,pdf" | csvsort -d "," -c name > $@

data/temp/%.nogermandecimals.csv: data/static/sources/%12E_Matrix.csv
	@echo "removing german decimals from $< to $@ ..."
	@sed "s/,00//g" $< > $@

data/temp/%.normalised.csv: data/temp/%.nogermandecimals.csv
	@echo "normalising $< to $@ ..."
	@csvformat -d ";" $< > $@

normalise: data/temp data/temp/EWR2001.normalised.csv data/temp/EWR2002.normalised.csv data/temp/EWR2003.normalised.csv data/temp/EWR2004.normalised.csv data/temp/EWR2005.normalised.csv data/temp/EWR2006.normalised.csv data/temp/EWR2007.normalised.csv data/temp/EWR2008.normalised.csv data/temp/EWR2009.normalised.csv data/temp/EWR2010.normalised.csv data/temp/EWR2011.normalised.csv data/temp/EWR2012.normalised.csv data/temp/EWR2013.normalised.csv data/temp/EWR2014.normalised.csv data/temp/EWR2015.normalised.csv data/temp/EWR2016.normalised.csv data/temp/EWR2017.normalised.csv data/temp/EWR2018.normalised.csv data/temp/EWR2019.normalised.csv data/temp/EWR2020.normalised.csv 

# This target creates the RDF file that serves as the input to the static site generator.
# All data should be merged in this file. This should include at least the VOID dataset
# description and the actual data.
# The target works by merging all prerequisites 
data/temp/all.nt: data/temp void.ttl data/temp/berlinonline.ttl data/vocab/einwohner.ttl
	@echo "combining $(filter-out $<,$^) to $@ ..."
	@rdfpipe -o ntriples $(filter-out $<,$^) > $@

cbds: _includes/cbds data/temp/all.nt
	@echo "computing concise bounded descriptions for all subjects in input data"
	@python bin/compute_cbds.py --base="$(base_uri)"

.PHONY: serve-local
serve-local: data/temp/all.nt cbds
	@echo "serving local version of static LOD site ..."
	@bundle exec jekyll serve

clean: clean-temp clean-cbds clean-jekyll

clean-temp:
	@echo "deleting temp folder ..."
	@rm -rf data/temp

data/temp:
	@echo "creating temp directory ..."
	@mkdir -p data/temp

_includes/cbds:
	@echo "creating $@ directory ..."
	@mkdir -p $@

clean-cbds:
	@echo "deleting cbd folder ..."
	@rm -rf _includes/cbds

clean-jekyll:
	@echo "deleting jekyll artifacts ..."
	@rm -rf _site
	@rm -rf .jekyll-cache