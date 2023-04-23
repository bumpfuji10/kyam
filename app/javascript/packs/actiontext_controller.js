var Trix = require("trix")
require("@rails/actiontext")

Trix.config.blockAttributes.heading1 = {
  tagName: "h5"
}

Trix.config.textAttributes.bold = {
  tagName: "b"
}

document.addEventListener("trix-initialize", function(event) {
  const toolbarElement = event.target.toolbarElement
  const editorElement = event.target.editor.element

  editorElement.parentElement.insertBefore(toolbarElement, editorElement.nextSibling)

  toolbarElement.style.display = "block"
  toolbarElement.style.marginTop = "10px"
})

