$(document).ready(function(){

  var navigationLinks = $("#sidebar a");
  var navigationPanels = $("#page > section");

  // initial preparation
  (function() {
    var CURRENT_YEAR = (new Date()).getFullYear();

    var URL_HASH = window.location.hash;
    var preload = navigationPanels.filter(URL_HASH);

    // update copyright year
    $("#year").html(CURRENT_YEAR);

    // friendlier amount time spent at each job
    $("#employment h4").hover(function() {
      var box = $(this).find('.box');
      var time = box.clone();

      var font = 0;
      var message = "";
      var months = 0;
      var years = 0;
      var start = box.html().split("-")[0];
      var end = box.html().split("-")[1];

      // safari likes to see a day, not just month year
      start = (start.match(/(\w{3}) (\d{4})/) || []).splice(1,2).join(" 1, ");
      end = (end.match(/(\w{3}) (\d{4})/) || []).splice(1,2).join(" 1, ");

      start = new Date(start);
      end = new Date(end);

      // fix 'present' value
      end = end == "Invalid Date"? new Date(): end;

      // calculate the amount of months
      months = (end.getFullYear() - start.getFullYear()) * 12;
      months -= start.getMonth() + 1;
      months += end.getMonth() + 1;

      // calculate the amount of years
      years = parseInt(months / 12, 10);
      months = parseInt(months % 12, 10);

      // years
      if (years > 0) {
        message = years + ' year';
        if (years > 1) {
          message += 's';
        }
      }

      // months
      if (months > 0) {
        if (years > 0) {
           message += ' and ';
        }
        message += months + ' month';
        if (months > 1) {
          message += 's';
        }
      }

      time.css({
        'visibility': 'hidden',
        'width': box.width(),
        'position': 'relative',
        'right': -1 * box.innerWidth(),
        'textAlign': 'center'
      });
      time.html(message).attr('title', message);
      box.after(time); // attach the human readable time

      font = parseInt(time.css('font-size'), 10);
      while (time.height() > box.height() && font > 4) {
        time.css('font-size', font--);
      }

      time.css({
        'visibility': '',
        'height': box.height()
      }).hide();

      box.stop();
      box.animate({opacity:0});

      time.fadeIn();
    }, function() {
      var box = $(this).find('.box');
      var time = box.next();

      box.stop();
      box.animate({opacity:1});
      time.remove();
    });

    // hide all panels
    navigationPanels.addClass("hidden");

    // if theres a hash in the URL start with that panel open
    if (preload.length === 1) {
      preload.removeClass("hidden");
      navigationLinks.filter("[href=" + URL_HASH + "]").addClass("bold");
    } else {
      navigationPanels.first().removeClass("hidden");
      navigationLinks.first().addClass("bold");
    }
  })();

  // breakdown animation -- fixes double-click bug with slideToggle()
  function toggleBreakdown() {
    var element = $(this);

    element.children("img").slideToggle("slow", function(){
      element.unbind("click").one("click", toggleBreakdown);
    });
  }

  // image breakdown for tags
  $(".breakdown").hover(function() {
      $(this).children("img").hide();
    }, function(){
      $(this).unbind("click").one("click", toggleBreakdown).children("img").stop().removeAttr('style');
    }
  ).one("click", toggleBreakdown);

  // navigation handling
  navigationLinks.click(function() {
    var navigationLink = $(this);
    var element = $(navigationLink.attr("href"));

    navigationPanels.addClass("hidden");
    navigationLinks.removeClass("bold");
    navigationLink.addClass("bold");

    // to use animations the element needs to be hidden (not with a class)
    element.hide().removeClass("hidden").fadeIn();
  });

});
