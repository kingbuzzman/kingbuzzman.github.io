http://www.buzzi.me/


# Installation

```
docker build -t kingbuzzman-ui .
```

# Generating static content

```
docker run -it -v $(pwd):/code --rm -p 8000:8000 kingbuzzman-ui
```
