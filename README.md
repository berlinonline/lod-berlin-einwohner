# Berlin Demographic Data as Linked Open Data

This repository contains demographical data for Berlin. 
The data is structured geographically by [LOR-Planungsraum](https://www.berlin.de/sen/sbw/stadtdaten/stadtwissen/sozialraumorientierte-planungsgrundlagen/lebensweltlich-orientierte-raeume/) units and temporally by year.
For each year/Planungsraum the data contains the total population, population by gender and population by age.

The dataset is a conversion of the source data CSV files, as published by the [Amt für Statistik Berlin-Brandenburg](https://www.statistik-berlin-brandenburg.de).

The data is converted using a series of scripts and tools, all orchestrated by the [Makefile](Makefile).

It is then published as Linked Open Data using the [LOD Site Generator](https://github.com/berlinonline/lod-sg) repository as a template.

**[Start browsing the data!](https://berlinonline.github.io/lod-berlin-einwohner/)**

## License

All code in this repository is published under the [MIT License](License). All data (in particular [void.ttl](void.ttl) and [data/target/lors.ttl](data/target/lors.ttl)) are published under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).