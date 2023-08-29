base_uri = https://berlinonline.github.io/lod-berlin-einwohner/
berlinonline_url = https://raw.githubusercontent.com/berlinonline/lod-berlin-bo/main/data/static/berlinonline.ttl
UNAME_S := $(shell uname -s)

data/temp/berlinonline.ttl: data/temp
	@echo "downloading $(berlinonline_url)..."
	@curl -s -o $@ "$(berlinonline_url)"

data/temp/variable_property_mapping.csv: data/temp data/vocab/demvoc.ttl
	@echo "extracting AfS variable to RDF property mapping from $(filter-out $<,$^) ..."
	@arq --data=$(filter-out $<,$^) --query=query/variable_property_mapping.rq --results=CSV > $@

data/temp/%.nogermandecimals.csv: data/static/sources/%_Matrix.csv
	@echo "removing german decimals from $< to $@ ..."
	@sed "s/,00//g" $< > $@

data/temp/%.normalised.csv: data/temp/%.nogermandecimals.csv
	@echo "normalising $< to $@ ..."
	@csvformat -d ";" $< > $@

data/temp/%.ttl: data/temp/variable_property_mapping.csv data/temp/%.normalised.csv
	@echo "generating RDF from $(filter-out $<,$^) ..."
	@echo "writing to $@ ..."
	@python bin/csv2cube.py --source $(filter-out $<,$^) --output $@

data/temp/%_extended.nt: data/temp data/temp/%.ttl data/vocab/demvoc.ttl
	@echo "combining $(filter-out $<,$^) to $@ ..."
	@rdfpipe -o ntriples $(filter-out $<,$^) > $@

data/temp/all_commons.ttl:
	@echo "merging common stuff of all RDF cubes ..."
	@echo "writing to $@ ..."
	@rdfpipe -o turtle data/temp/EWR20*E_common.ttl > $@

data/temp/base_data.nt: data/temp data/temp/all_commons.ttl void.ttl data/temp/berlinonline.ttl data/vocab/demvoc.ttl
	@echo "combining $(filter-out $<,$^) to $@ ..."
	@rdfpipe -o ntriples $(filter-out $<,$^) > $@

_partial_sites/_config_common.yml: _partial_sites data/temp/base_data.nt
	@echo "generating partial config for $(filter-out $<,$^) ..."
	@echo "writing to $@ ..."
	@sed 's|$$SOURCE_PATH|$(filter-out $<,$^)|' _config_template_common.yml > $@

cbds_common: _includes/cbds data/temp/base_data.nt 
	@echo "computing concise bounded descriptions for all subjects in $(filter-out $<,$^) ..."
	@python bin/compute_cbds.py --base="$(base_uri)" --source $(filter-out $<,$^) --output $<

_partial_sites/_site_common: cbds_common _partial_sites/_config_common.yml
	@echo "generating partial site $@ ..."
	@bundle exec jekyll build --config $(filter-out $<,$^) --destination $@

_partial_sites/_config_%.yml: _partial_sites data/temp/%_extended.nt
	@echo "generating partial config for $(filter-out $<,$^) ..."
	@echo "writing to $@ ..."
	@sed 's|$$SOURCE_PATH|$(filter-out $<,$^)|' _config_template.yml > $@

cbds_%: _includes/cbds data/temp/%_extended.nt
	@echo "computing concise bounded descriptions for all subjects in $(filter-out $<,$^) ..."
	@python bin/compute_cbds.py --base="$(base_uri)" --source $(filter-out $<,$^) --output $<

_partial_sites/_site_%: cbds_% _partial_sites/_config_%.yml
	@echo "generating partial site $@ ..."
	@bundle exec jekyll build --config $(filter-out $<,$^) --destination $@

# partial-sites: _partial_sites/_site_EWR201012E _partial_sites/_site_common 
partial-sites: _partial_sites/_site_EWR201012E _partial_sites/_site_EWR201112E _partial_sites/_site_EWR201212E _partial_sites/_site_EWR201312E _partial_sites/_site_EWR201412E _partial_sites/_site_EWR201512E _partial_sites/_site_EWR201612E _partial_sites/_site_EWR201712E _partial_sites/_site_EWR201812E _partial_sites/_site_EWR201912E _partial_sites/_site_EWR202012E _partial_sites/_site_common 

merge-sites: partial-sites _site
	@echo "merging all partial sites into $(filter-out $<,$^) ..."
	@if [ $(UNAME_S) = "Linux" ]; then\
		cp -n -R _partial_sites/*/* $(filter-out $<,$^)/;\
	fi
	@if [ $(UNAME_S) = "Darwin" ]; then\
		cp -R _partial_sites/*/* $(filter-out $<,$^)/;\
	fi

data/temp/all.nt: data/temp/base_data.nt data/temp/all_cubes.ttl
	@echo "combining $^ to $@ ..."
	@rdfpipe -o ntriples $^ > $@

# Housekeeping (create folders, clean/delete stuff)

.PHONY: all
all: data/temp/all.nt cbds

.PHONY: serve-local
serve-local: all
	@echo "serving local version of static LOD site ..."
	@bundle exec jekyll serve

clean: clean-temp clean-cbds clean-jekyll clean-partial_sites

clean-temp:
	@echo "deleting temp folder ..."
	@rm -rf data/temp

data/temp:
	@echo "creating temp directory ..."
	@mkdir -p $@

_partial_sites:
	@echo "creating $@ directory ..."
	@mkdir -p $@

_site:
	@echo "creating $@ directory ..."
	@mkdir -p $@

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

clean-partial_sites:
	@echo "deleting _partial_sites folder ..."
	@rm -rf _partial_sites

# optional stuff (do some interesting stuff that is not really needed)

# extract the list of relevant datasets from the Datenregister metadata dump
data/temp/datasetlist.json: data/temp
	@cat $(datenregister_dump) | jq '[.datasets[] | select(.title | startswith("Einwohnerinnen und Einwohner in Berlin in LOR-Planungsräumen am")) | { title: .title, name: .name, csv: .resources[] | select(.format == "CSV") | .url, pdf: .resources[] | select(.format == "PDF") | .url } ]' > $@

# create a CSV from the JSON list
data/temp/datasetlist.csv: data/temp/datasetlist.json
	@cat $< | jq -r '(map(keys) | add | unique) as $$cols | map(. as $$row | $$cols | map($$row[.])) as $$rows | $$cols, $$rows[] | @csv' | csvcut -d "," -c "name,title,csv,pdf" | csvsort -d "," -c name > $@

# normalise all source data
normalise: data/temp data/temp/EWR200112E.normalised.csv data/temp/EWR200212E.normalised.csv data/temp/EWR200312E.normalised.csv data/temp/EWR200412E.normalised.csv data/temp/EWR200512E.normalised.csv data/temp/EWR200612E.normalised.csv data/temp/EWR200712E.normalised.csv data/temp/EWR200812E.normalised.csv data/temp/EWR200912E.normalised.csv data/temp/EWR201012E.normalised.csv data/temp/EWR201112E.normalised.csv data/temp/EWR201212E.normalised.csv data/temp/EWR201312E.normalised.csv data/temp/EWR201412E.normalised.csv data/temp/EWR201512E.normalised.csv data/temp/EWR201612E.normalised.csv data/temp/EWR201712E.normalised.csv data/temp/EWR201812E.normalised.csv data/temp/EWR201912E.normalised.csv data/temp/EWR202012E.normalised.csv 

# generate RDF from all source data
generate-rdf: data/temp data/temp/EWR200112E.ttl data/temp/EWR200212E.ttl data/temp/EWR200312E.ttl data/temp/EWR200412E.ttl data/temp/EWR200512E.ttl data/temp/EWR200612E.ttl data/temp/EWR200712E.ttl data/temp/EWR200812E.ttl data/temp/EWR200912E.ttl data/temp/EWR201012E.ttl data/temp/EWR201112E.ttl data/temp/EWR201212E.ttl data/temp/EWR201312E.ttl data/temp/EWR201412E.ttl data/temp/EWR201512E.ttl data/temp/EWR201612E.ttl data/temp/EWR201712E.ttl data/temp/EWR201812E.ttl data/temp/EWR201912E.ttl data/temp/EWR202012E.ttl 
