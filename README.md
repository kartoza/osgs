# Open Source GIS Stack

```
  ___  ___  __ _ ___
 / _ \/ __|/ _` / __|
| (_) \__ \ (_| \__ \
 \___/|___/\__, |___/
           |___/
The Open Source GIS Stack
```

The Open Source GIS Stack (OSGS) is a rich, integrated, and opinionated GIS Stack with a focus on configurability and ease of use built from Open Source Components.

</br>
  <a href="https://osgs.kartoza.com/">
    <div style="display: inline-block;">
    <img src="https://raw.githubusercontent.com/kartoza/osgs/main/conf/hugo_conf/site_template/static/logos/logo.svg"
        style="vertical-align:middle; width: 50px; height:50px;" alt="OSGS ICON" />
        <div style="vertical-align:middle; display:inline; font-size: 2rem; font-weight: bold; margin-left: 16px">
          VIEW DEMO
        </div>
    </div>
  </a>
</br>
</br>

## Documentation

The documentation site is available at https://kartoza.github.io/osgs/

The documentation site content is available as static resources in the `docs` directory.

You can contribute to the documentation by making changes to resources located in `sphinx/source/`.

## Project Roadmap

The project roadmap is outlined in the documentation here: https://kartoza.github.io/osgs/roadmap.html

Note that this may have implications on the deployment strategy and implementation.

## Quickstart

Basic steps to get OSGS up and running.

Impatient users can try `make configure-ssl-self-signed` to run through configuration, and `make deploy` to deploy the stack.

### Prerequisites

- [make](https://www.gnu.org/software/make/)
- [rpl](https://linux.die.net/man/1/rpl)
- [git](https://git-scm.com/)
- [docker compose](https://docs.docker.com/compose/) (must install from pip3)

A more complete outline of server configuration is available in the documentation https://kartoza.github.io/osgs/installation/server_preparation.html

### Windows

Note that the stack is designed to be run on linux.

Make is available on Windows using various installation methods, including [chocolatey](https://community.chocolatey.org/packages/make). Whilst it is technically feasible to configure and run the system on Docker for Windows, or using Windows Subsystem for Linux, there have been numerous issues in the past with this approach and it is recommended that the stack is run in a virtual machine when deployed on windows infrastructure.

### Setup Domain Name

Before setting up the project you will need to define a fully qualified domain name ([FQDN](https://en.wikipedia.org/wiki/Fully_qualified_domain_name)) and ensure that the routing is correctly configured for communication with trhe server using that domain name. For local deployments it is recommended that the relevant fqdn is defined in the [hosts file](https://linuxize.com/post/how-to-edit-your-hosts-file/).

### Clone Repository

Navigate to or create your relevant content directory, e.g. `/web/`, and clone the repository with git:

```bash
git clone https://github.com/kartoza/osgs
```

### Run Installation Wizard

Open your OSGS directory (e.g. `$ cd /web/osgs`) and run the configuration wizard.

If you are going to use a self-signed certificate (e.g. on localhost for testing):

```bash
make configure-ssl-self-signed
```

If you are going to use a letsencrypt signed certificate on a named host (for production servers with a domain name):

```bash
make configure-letsencrypt-ssl
```

Once configuration is complete, start the service with `make deploy`.

Additional configuration commands may be reviewed with `make help`.

### Review Installation Documentation

The problems and infrastructure that OSGS intends to provide solutions for are complex and fairly nuanced. It is recommended that users read through the installation documentation to understand the platform from https://kartoza.github.io/osgs/installation/index.html

## About

Location is hard. Geospatial data management platforms may provide solutions across various domains, including data storage, spatial analysis, earth observation, geodata service exposure, desktop, web and other client software integrations, additional data visualisation or business intelligence tools, and many others. This is further complicated by complex data structures and data types, which are even more challenging when managing additional data sources such as streaming or event driven processes, service monitoring, access control, data security, and many others.

Proprietary systems that provide complete end to end solutions are typically very expensive, or only provide a small subset of the desired functionality.

The Open Source Geospatial community provides a wide variety of tools suited to performing some specific functionalities, and whilst there are many integrations between these solutions and platforms, they often require a large amount of configuration and significant technical expertise to ensure that the integration operates effectively. Very often, just the number of available platform choices can seem overwhelming.

The OSGS attempts to resolve this by providing an opinionated platform with preconfigured components to provide a number of generic workflows and solutions, whilst providing the flexibility, extensibility, and value benefits of open source.

The advanced configuration management tools also provide a level of granular control for administrators to define exactly which services are desired, with the entire stack designed with ease of use in mind for setup, deployment, and use.

## Philosophy

By being opinionated, the stack provides a mechanism for being a "one stop shop" for the vast majority of open source spatial system needs. In particular, the stack aims to:

- Lower barriers to entry for advanced spatial data services
- Provide a 'click-to-run' experience for supporting spatial infrastructures
- Simplify configuration and management for complex solutions
- Promote the usage and adoption of Open Source GIS tools and platforms
- Create meaningful blueprints for data lifecycle management and location intelligence solutions
- Remain flexible while providing sensible default configurations

## Architecture

The stack is designed for deployment with docker-compose, with planned support for k8s. Service management is handled by an [Nginx](https://nginx.org/) proxy and web server service. The default configuration makes provisions for various configurations viadocker compose profiles, including some default load balancing and clustering operations.

### Key Services

OSGS Provides support and integration for a wide variety of services, with a key focus being on:

- [PostgreSQL with the PostGIS](https://postgis.net/) extension for spatial data storage, analysis, and data services
- [Docker-OSM](https://github.com/kartoza/docker-osm) for getting some enriched starting data from [OpenStreetMap](https://www.openstreetmap.org/about) within a defined area of interest
- A static [website built with hugo](https://gohugo.io/) that automatically deploys changes and provides templates and shortcodes for web maps using the [osgs-hugo-watcher](https://github.com/kartoza/hugo-watcher) image
- [QGIS Server](https://docs.qgis.org/latest/en/docs/server_manual/index.html) integration for dynamic spatial data services and WYSIWYG web map service provision
- [MapProxy](https://mapproxy.org/) for providing metatiling, caching, and additional service provision
- [Mergin](https://public.cloudmergin.com/) and [Input](https://inputapp.io/) integration for field mapping services
- [File Browser](https://filebrowser.org/) for simple and interactive data management for remote services
- [SCP](https://en.wikipedia.org/wiki/Secure_copy_protocol) service for simple and user friendly flat file access that integrates neatly with services
- [PostgREST](https://postgrest.org/) and [OpenAPI](https://swagger.io/specification/) endpoints to facilitate development and integration
- [Metabase](https://www.metabase.com/) open source business intelligence tool for visualising and analysing data, which provides some great widgets that integrate into webpages

### Additional Services

A number of additional value added services are included as well, including, but not limited to:

- [QGIS Desktop](https://docs.qgis.org/3.16/en/docs/user_manual/index.html) (Integrated with stack and remotely access via browser based UI)
- [Geoserver](http://geoserver.org/)
- [LizMap](https://www.lizmap.com/)
- [NodeRed](https://nodered.org/)
- [Jupyter Notebooks](https://jupyter.org/)
- [OpenDroneMap](https://www.opendronemap.org/)

### "Plumbing"

Various services also run under the hood to facilitate platform operations and ensure a pleasant user experience. Typically these services are used when debugging issues or for maintenance operations by system administrators, and may include:

- [Hugo Watcher](https://github.com/kartoza/hugo-watcher), a utility that watches for file system changes and triggers a rebuild with the static site builder. [Windows users may encounter some issues with this service](https://github.com/zacharlie/hot-flask#wsl2-docker-file-watching).
- Mergin components: Mergin is a platform which provides various functions, including access control, data synchronization, versioning, and data management. The server component may be configured to leverage the public mergin cloud service (commercial projects are required to pay a subscription), or a local instance of Mergin may be configured within OSGS (with some caveats). Additionally, the Mergin service includes a client for data synchronization, and the mergin-db-sync client is used to synchronize data between Mergin and a PostgreSQL database.

## Configuration

Configuration is currently handled by make processes, with an admin interface under development. It is possible to configure the services by editing the .env and docker-compose files directly, but due to the complexity involved with service configuration, this is not recommended.

## Key Considerations

The following considerations are detailed in the documentation, however are considered critical for any intended deployment.

### Hosting

How you manage and deploy your infrastructure is up to you, and identifying which services should be exposed publicly and which should not will depend on the intended use case. The OSGS simply tries to provide some sensible defaults, but each service included typically supports multiple configuration options. contact [Kartoza](https://kartoza.com/) for commercial support.

### Authentication

Currently authentication is mainly managed with [Basic access authentication](https://en.wikipedia.org/wiki/Basic_access_authentication) to control access to particular services, with additional authentication and access control being provided by individual stack components.

### SSL

The config wizard supports automatic letsencrypt certificate creation for production deployment and self signed certificates for local deployments and development. Provision of user supplied certificates planned for future release.

## Contributing

Community contributions are welcome, and should adhere to the [QGIS Code of Conduct](https://qgis.org/en/site/getinvolved/governance/codeofconduct/codeofconduct.html)

## Support

Whilst we welcome the community to contribute via raising issues in GitHub, addressing these will be undertaken only on a best effort basis. If you require a commercial support contract, please contact [Kartoza](https://kartoza.com/).

</br>
</br>
<p align="center">
  <a href="https://kartoza.com/">
    <img src="https://user-images.githubusercontent.com/64078329/132987788-89d8b1cb-7853-4080-a2f4-20e8c587da01.png" alt="Kartoza Logo" />
  </a>
</p>
