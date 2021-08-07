# Obtaining free fonts for your projects

There are two great sources of free fonts that you can use for your projects:

http://ftp.gnu.org/gnu/freefont/freefont-ttf-20120503.zip
https://fonts.google.com/

There is a makefile target that can be run with:

```
make get-fonts
```

That will fetch all of these fonts for you. If you also fetch these fonts on your local machine and place them in your ``~/.fonts`` folder then you can use them in your local QGIS projects, know they will also be available to QGIS server if you publish that project as a web map.

**Note:** This and other makefile targets assume that you have not changed the ``COMPOSE_PROJECT_NAME=osgisstack`` environment variable in .env.

**Note:** The above make command fetches a rather large download!

