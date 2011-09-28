mkdir js
mkdir css
mkdir images

curl http://localhost:9000/ > index.html
curl http://localhost:9000/js/main.js > js/main.js
curl http://localhost:9000/css/main.css > css/main.css
curl http://localhost:9000/css/print.css > css/print.css
curl http://localhost:9000/images/body_bg.png > images/body_bg.png
curl http://localhost:9000/images/sprites.png > images/sprites.png