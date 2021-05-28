---
title: Creating Content
subtitle: How to add content to the site
images:
- "/unsplash/photo-1619468129361-605ebea04b44.jpg"
categories:
- Documentation
- System
summary: "How to  generate and publish content, utilising the relevant markdown and custom designed blocks for platform components."
---

This site supports the creation of two main content types - Maps and documents.

All content is stored as flat file plaintext documents in the relevant sections. The section defines the content type for each page and how it is renders on the site. The site uses [Markdown](https://commonmark.org/) for content styling, as well as various custom style definitions as illustrated in the [sample](/docs/sample) document.

[Page metadata](https://gohugo.io/content-management/front-matter/) is stored within each file at the top using [yaml](https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html) and allows custom page behaviours to be defined dynamically for all content within a page.

## Maps

Map pages will automatically create an open layers map. The position and zoom level of the map at page load is defined in the page metadata.

Adding WMS layers may be done by configuring the relevant page metadata and specifying the WMS endpoint URL and the layers to be included.

{{< highlight text "linenos=table" >}}

lat: 51.505
long: -0.09
zoom: 13
wms: "http://146.185.160.86/geoserver/wfs?"
layers:
- "geonode:schools"
- "geonode:churches"
- "geonode:police_stations"

{{< / highlight >}}

Multiple layers may be included as a single map layer, however, only the use of a single WMS is supported at this time.

To create a new map, simply copy and paste the relevant demo document on the file system and edit accordingly.

## Documents

Documents are simple web pages which render the page contents from markdown into a complete webpage with the appropriate style sheets etc. More advanced functionality is available with custom code blocks as displayed in the included samples.
