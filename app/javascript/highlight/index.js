import hljs from 'highlight.js'
import 'highlight.js/styles/monokai-sublime.css';

hljs.configure({ languages: ['ruby', 'bash', 'javascript'] })
document.addEventListener('turbolinks:load', (event) => {
  document.querySelectorAll('pre').forEach((block) => {
    hljs.highlightBlock(block)
  })
})
