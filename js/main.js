$(document).ready(function() {
  var navigationLinks, navigationPanels, toggleBreakdown;
  toggleBreakdown = function() {
    var element;
    element = $(this);
    element.children("img").slideToggle("slow", function() {
      element.unbind("click").one("click", toggleBreakdown);
    });
  };
  navigationLinks = $("#sidebar a");
  navigationPanels = $("#page > section");
  (function() {
    var CURRENT_YEAR, URL_HASH, preload;
    CURRENT_YEAR = (new Date()).getFullYear();
    URL_HASH = window.location.hash;
    preload = navigationPanels.filter(URL_HASH);
    $("#year").html(CURRENT_YEAR);
    $("#employment h5").hover((function() {
      var box, end, font, message, months, start, time, years;
      box = $(this).find(".time");
      time = box.clone();
      font = 0;
      message = "";
      months = 0;
      years = 0;
      start = box.html().split("-")[0];
      end = box.html().split("-")[1];
      start = (start.match(/(\w{3}) (\d{4})/) || []).splice(1, 2).join(" 1, ");
      end = (end.match(/(\w{3}) (\d{4})/) || []).splice(1, 2).join(" 1, ");
      start = new Date(start);
      end = new Date(end);
      end = (end.toString() === "Invalid Date" ? new Date() : end);
      months = (end.getFullYear() - start.getFullYear()) * 12;
      months -= start.getMonth() + 1;
      months += end.getMonth() + 1;
      years = parseInt(months / 12, 10);
      months = parseInt(months % 12, 10);
      if (years > 0) {
        message = years + " year";
        if (years > 1) {
          message += "s";
        }
      }
      if (months > 0) {
        if (years > 0) {
          message += " and ";
        }
        message += months + " month";
        if (months > 1) {
          message += "s";
        }
      } else {
        if (years === 0) {
          message = "Present";
        }
      }
      time.css({
        visibility: "hidden",
        width: box.width(),
        position: "relative",
        right: -1 * box.innerWidth(),
        textAlign: "center"
      });
      time.html(message).attr("title", message);
      box.after(time);
      font = parseInt(time.css("font-size"), 10);
      while (time.height() > box.height() && font > 4) {
        time.css("font-size", font--);
      }
      time.css({
        visibility: "",
        height: box.height()
      }).hide();
      box.stop();
      box.animate({
        opacity: 0
      });
      time.fadeIn();
    }), function() {
      var box, time;
      box = $(this).find(".box");
      time = box.next();
      box.stop();
      box.animate({
        opacity: 1
      }, function() {
        box.removeAttr("style");
      });
      time.remove();
    });
    navigationPanels.addClass("hidden");
    if (preload.length === 1) {
      preload.removeClass("hidden");
      navigationLinks.filter("[href=" + URL_HASH + "]").addClass("bold");
    } else {
      navigationPanels.first().removeClass("hidden");
      navigationLinks.first().addClass("bold");
    }
  })();
  $(".breakdown").hover(function() {
    $(this).children("img").hide();
  }, function() {
    $(this).unbind("click").one("click", toggleBreakdown).children("img").stop().removeAttr("style");
  }).one("click", toggleBreakdown);
  navigationLinks.click(function() {
    var element, navigationLink;
    navigationLink = $(this);
    element = $(navigationLink.attr("href"));
    navigationPanels.addClass("hidden");
    navigationLinks.removeClass("bold");
    navigationLink.addClass("bold");
    element.hide().removeClass("hidden").fadeIn();
  });
});
