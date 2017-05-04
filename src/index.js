require('./main.css')
const logoPath = require('./logo.svg')
const Elm = require('./App.elm')

const domNode = document.getElementById('main')

Elm.App.embed(domNode, logoPath)
