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
      years = months / 12;

      if (parseInt(years, 10) > 0) {
        message = years.toFixed(2) + ' years';
      } else {
        message = months + ' months';
      }

      time.hide();
      time.css({
        'width': box.width(),
        'position': 'relative',
        'right': -1 * box.innerWidth(),
        'textAlign': 'center'
      });
      time.html(message);

      box.stop();
      box.animate({opacity:0});
      box.after(time); // attach the human readable time

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
