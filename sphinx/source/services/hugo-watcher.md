# Hugo Watcher

Hugo is a static site generator. Hugo builds pages when you create or update your content. Since websites are viewed far more often than they are edited, Hugo is designed to provide an optimal viewing experience for the website’s end users and an ideal writing experience for website authors. [[1]](#1)

The Hugo Watcher service watches for changes in the static content source files of the hugo site and rebuilds the site whenever a source file is changed.

**Service name:** hugo-watcher

**Project Website:** [HUGO](https://gohugo.io/)

**Project Source Repository:**  [gohugoio / hugo](https://github.com/gohugoio/hugo)

**Project Project Technical Documentation:** [Hugo Documentation](https://gohugo.io/documentation/)

**Docker Repository:** [kartoza/hugo-watcher](https://hub.docker.com/r/kartoza/hugo-watcher)

**Docker Source Repository:** [kartoza / hugo-watcher](https://github.com/kartoza/hugo-watcher)

## Deployment

```
make deploy-hugo
```

## Enabling

```
make enable-hugo
```

## Starting

```
make start-hugo
```

## Stopping 

```
make stop-hugo
```

## Disabling

```
make disable-hugo
```

## Logs

```
make hugo-logs
```

## Shell 

```
make hugo-shell
```

## Backing up data

```
make backup-hugo
```

## Restoring data

```
make restore-hugo
```

## Accessing the running services

## Additional Notes

## References

<a id="1">[1]</a> Hugo Authors. (2020, June 3). About Hugo. Hugo. https://gohugo.io/about/what-is-hugo/
