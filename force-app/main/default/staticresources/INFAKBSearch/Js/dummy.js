
(function (w) {

    try {
        
        
        function fnInitializeCopyEvent() {
            var clipboard =
            {
                  data: 'test',
                  intercept: false,
                  hook: function (evt) {
                        if (clipboard.intercept) {
                              evt.clipboardData.setData('text/plain', clipboard.data);
                              evt.preventDefault();

                              clipboard.intercept = false;
                              clipboard.data = '';
                        }
                  }
            };
            window.addEventListener('copy', clipboard.hook);
      }

        
        var dummyJs = {
          
            'fnInitializeCopyEvent' : fnInitializeCopyEvent
      
  
      };

      w.dummyJs = dummyJs;

    } catch (error) {
        console.error('error', 'dummy onInit : ' + error.message);
  }

  

})(window);