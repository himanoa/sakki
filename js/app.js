const Vue = require('../node_modules/vue/dist/vue.min.js');
const marked = require('marked');
const _ = require('lodash');
document.addEventListener("DOMContentLoaded", function(){
  if(!document.querySelector('#editor')){
    return ;
  }
  new Vue({
    el: '#editor',
    data: {
      input: document.querySelector('[data-text]').getAttribute('data-text')
    },
    computed:{
      mdToHtml: function(){
        return marked(this.input, { sanitize: true });
      }
    },
    methods: {
      update: _.debounce(function(e){
        this.input = e.target.value;
      }, 300)
    }
  })
})
