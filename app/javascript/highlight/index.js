import hljs from 'highlight.js'
import 'highlight.js/styles/monokai.css';
//import hljs from 'highlight.js/lib/highlight';

hljs.configure({ languages: ['ruby', 'bash', 'javascript'] })
document.addEventListener('turbolinks:load', (event) => {
  document.querySelectorAll('pre').forEach((block) => {
    hljs.highlightBlock(block)
  })
})
