style = document.createElement 'style'
    ..innerHTML = ig.data.style
font = document.createElement \link
  ..href = '//fonts.googleapis.com/css?family=Roboto:100,300,400,400italic,500,700,900&subset=latin,latin-ext'
  ..rel = 'stylesheet'
  ..type = 'text/css'


scriptData = document.createElement \script
  ..src = 'https://samizdat.cz/data/jizni-mesto/data/topo.js'

document.getElementsByTagName 'head' .0
  ..appendChild style
  ..appendChild font
  ..appendChild scriptData
