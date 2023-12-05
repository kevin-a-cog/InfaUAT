$(document).ready(function () {
  console.log("Doc Ready1");
  $("#es-navbar-search").on("click", function () {
    console.log("clicked");
    $(".es-navbar-search-form-wrapper").show();
  });
  $(".es-navbar-search-close").click(function () {
    console.log("clicked2");
    $(".es-navbar-search-form-wrapper").hide();
  });
});
var body = document.body;
body.classList.add("MyClass");

(function() {
  function resizeEditText() {
      console.log('hello from helloModule.js');
      
      let editCommentText = document.getElementsByTagName("textarea");
      // let editCommentText = this.template.querySelector('.es-autoresize .slds-textarea');

      console.log('hello from helloModule.js', editCommentText);
      // this.template.querySelector('.es-autoresize .slds-textarea').style.height = 'auto';
      // this.template.querySelector('.es-autoresize .slds-textarea').style.height = '400px';
      // console.log('hello from helloModule.js1');

      // for (let i = 0; i < tx.length; i++) {
      //   tx[i].setAttribute("style", "height:" + (tx[i].scrollHeight) + "px;overflow-y:hidden;");
      //   tx[i].addEventListener("input", OnInput, false);
      // }
      
      // function OnInput() {
      //   this.style.height = "auto";
      //   this.style.height = (this.scrollHeight) + "px";
      // }
      

  }
  // this makes the sayHello function available in the window     namespace
  // so we can call window.sayHello from any LWC JS file
  window.resizeEditText = resizeEditText;
})();