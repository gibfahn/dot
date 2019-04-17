document.addEventListener('DOMContentLoaded', function() {
   $.ajax({
      url: 'https://raw.githubusercontent.com/LanikSJ/slack-dark-mode/master/dark-theme.css',
      success: function(css) {
         $("<style></style>").appendTo('head').html(css);
      }
   });
});
