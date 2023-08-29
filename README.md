# Berlin Demographic Data as Linked Open Data

This repository contains demographical data for Berlin. 
The data is structured geographically by [LOR-Planungsraum](https://www.berlin.de/sen/sbw/stadtdaten/stadtwissen/sozialraumorientierte-planungsgrundlagen/lebensweltlich-orientierte-raeume/) units and temporally by year.
For each year/Planungsraum the data contains the total population, population by gender and population by age.

The dataset is a conversion of the source data CSV files, as published by the [Amt für Statistik Berlin-Brandenburg](https://www.statistik-berlin-brandenburg.de).

The data is converted using a series of scripts and tools, all orchestrated by the [Makefile](Makefile).

It is then published as Linked Open Data using the [LOD Site Generator](https://github.com/berlinonline/lod-sg) repository as a template.

**[Start browsing the data!](https://berlinonline.github.io/lod-berlin-einwohner/)**

## Sources

The following sources were used to generate the data in this repository:

- [Einwohnerinnen und Einwohner in Berlin in LOR-Planungsräumen am 31.12.2010](https://daten.berlin.de/datensaetze/einwohnerinnen-und-einwohner-berlin-lor-planungsräumen-am-31122010)
- [Einwohnerinnen und Einwohner in Berlin in LOR-Planungsräumen am 31.12.2011](https://daten.berlin.de/datensaetze/einwohnerinnen-und-einwohner-berlin-lor-planungsräumen-am-31122011)
- [Einwohnerinnen und Einwohner in Berlin in LOR-Planungsräumen am 31.12.2012](https://daten.berlin.de/datensaetze/einwohnerinnen-und-einwohner-berlin-lor-planungsräumen-am-31122012)
- [Einwohnerinnen und Einwohner in Berlin in LOR-Planungsräumen am 31.12.2013](https://daten.berlin.de/datensaetze/einwohnerinnen-und-einwohner-berlin-lor-planungsräumen-am-31122013)
- [Einwohnerinnen und Einwohner in Berlin in LOR-Planungsräumen am 31.12.2014](https://daten.berlin.de/datensaetze/einwohnerinnen-und-einwohner-berlin-lor-planungsräumen-am-31122014)
- [Einwohnerinnen und Einwohner in Berlin in LOR-Planungsräumen am 31.12.2015](https://daten.berlin.de/datensaetze/einwohnerinnen-und-einwohner-berlin-lor-planungsräumen-am-31122015)
- [Einwohnerinnen und Einwohner in Berlin in LOR-Planungsräumen am 31.12.2016](https://daten.berlin.de/datensaetze/einwohnerinnen-und-einwohner-berlin-lor-planungsräumen-am-31122016)
- [Einwohnerinnen und Einwohner in Berlin in LOR-Planungsräumen am 31.12.2017](https://daten.berlin.de/datensaetze/einwohnerinnen-und-einwohner-berlin-lor-planungsräumen-am-31122017)
- [Einwohnerinnen und Einwohner in Berlin in LOR-Planungsräumen am 31.12.2018](https://daten.berlin.de/datensaetze/einwohnerinnen-und-einwohner-berlin-lor-planungsräumen-am-31122018)
- [Einwohnerinnen und Einwohner in Berlin in LOR-Planungsräumen am 31.12.2019](https://daten.berlin.de/datensaetze/einwohnerinnen-und-einwohner-berlin-lor-planungsräumen-am-31122019)
- [Einwohnerinnen und Einwohner in Berlin in LOR-Planungsräumen am 31.12.2020](https://daten.berlin.de/datensaetze/einwohnerinnen-und-einwohner-berlin-lor-planungsräumen-am-31122020)

All datasets have been published by the [Amt für Statistik Berlin-Brandenburg](https://www.statistik-berlin-brandenburg.de) under a [CC BY 3.0 DE](http://creativecommons.org/licenses/by/3.0/de/).

## License

All code in this repository is published under the [MIT License](License). All data (except for the sources as listed above) are published under [CC0](https://creativecommons.org/publicdomain/zero/1.0/).