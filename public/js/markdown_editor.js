document.addEventListener("DOMContentLoaded", function(){
  if(!document.querySelector('#editor')){
    return ;
  }
  new Vue({
    el: '#editor',
    data: {
      input: ''
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
