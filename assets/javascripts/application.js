// a few constants for animations speeds, etc.
var animationRate = 100;
var animationEasing = 'linear';

/* jQuery code from #263 */
// returns viewport height
jQuery.viewportHeight = function() {
     return self.innerHeight ||
        jQuery.boxModel && document.documentElement.clientHeight ||
        document.body.clientHeight;
};

/*
 * Expands Redmine's current menu
 */
(function($) {
  $.menu_expand = function(options) {
      var opts = $.extend({
          menu: '#main-menu',
          menuItem: '.selected'
      }, options);

      $(opts.menu +' '+ opts.menuItem).toggleClass("open").siblings("ul").show();

  }})(jQuery);

// Toggle a top menu item open or closed, showing or hiding its submenu
function toggleTopMenu(menuItem) {
  menuItem.toggleClass("open").find('ul').slideToggle({ duration: animationRate, easing: animationEasing });
};

// Handle a single click event on the page to close an open menu item

function handleClickEventOnPageToCloseOpenMenu(openMenuItem) {
  $('html').one("click", function(htmlEvent) {
    if (openMenuItem.has(htmlEvent.target).length > 0) {
      // Clicked on the open menu, let it bubble up
    } else {
      // Clicked elsewhere, close menu
      toggleTopMenu(openMenuItem);
    }
  });
};

$(function(){

  // open and close the main-menu sub-menus
  $("#main-menu li:has(ul) > a").not("ul ul a")
  	.append("<span class='toggler'></span>")
  	.click(function() {

  		$(this).toggleClass("open").parent().find("ul").not("ul ul ul").slideToggle({ duration: animationRate, easing: animationEasing });

  		return false;
  });

  // submenu flyouts
  $("#main-menu li li:has(ul)").hover(function() {
  	$(this).find(".profile-box").show();
  	$(this).find("ul").slideDown({ duration: animationRate, easing: animationEasing });
  }, function() {
  	$(this).find("ul").slideUp({ duration: animationRate, easing: animationEasing });
  });

  // add filter dropdown menu
  // $(".button-large:has(ul) > a").click(function(event) {
  //   var tgt = $(event.target);
  //
  //   // is this inside the title bar?
  //   if (tgt.parents().is(".title-bar")) {
  //     $(".title-bar-extras:hidden").slideDown({ duration: animationRate, easing: animationEasing });
  //   }
  //
  //   $(this).parent().find("ul").slideToggle({ duration: animationRate, easing: animationEasing });
  //
  //   return false;
  // });

  // Toggle a top menu item open or closed, showing or hiding its submenu
  // function toggleTopMenu(menuItem) {
  //   menuItem.toggleClass("open").find('ul').slideToggle({ duration: animationRate, easing: animationEasing });
  // };

  // Click on the menu header with a dropdown menu
  $('#account-nav .drop-down').on('click', function(event) {
    var menuItem = $(this);
    var menuUl = menuItem.find('> ul');

    menuUl.css('height', 'auto');
    if(menuUl.height() > $.viewportHeight()) {
      var windowHeight = $.viewportHeight() - 150;
      menuUl.css({'height': windowHeight});
    }

    toggleTopMenu(menuItem);

    if (menuItem.hasClass('open')) {
      handleClickEventOnPageToCloseOpenMenu(menuItem);
    }
    return false;
  });

  // Click on an actual item
  $('#account-nav .drop-down ul a').on('click', function(event) {
    event.stopPropagation();
  });

  // show/hide login box
  $("#account-nav a.login").click(function() {
    $(this).parent().toggleClass("open");
    // Focus the username field if the login field has opened
    $("#nav-login").slideToggle({ duration: animationRate, easing: animationEasing, done: function () {
      if ($(this).parent().hasClass("open")) {
        $("input#username-pulldown").focus()
      }
    }});
  
    return false;
  });

  // deal with potentially problematic super-long titles
  $(".title-bar h2").css({paddingRight: $(".title-bar-actions").outerWidth() + 15 });

  // rejigger the main-menu sub-menu functionality.
  $("#main-menu .toggler").remove(); // remove the togglers so they're inserted properly later.

  $("#main-menu li:has(ul) > a").not("ul ul a")
  	// 1. unbind the current click functions
  	.unbind("click")
  	// 2. wrap each in a span that we'll use for the new click element
  	.wrapInner("<span class='toggle-follow'></span>")
  	// 3. reinsert the <span class="toggler"> so that it sits outside of the above
  	.append("<span class='toggler'></span>")
  	// 4. attach a new click function that will follow the link if you clicked on the span itself and toggle if not
  	.click(function(event) {

  		if (!$(event.target).hasClass("toggle-follow") ) {
  			$(this).toggleClass("open").parent().find("ul").not("ul ul ul").slideToggle({ duration: animationRate, easing: animationEasing });
  			return false;
  		}
  	});

  // Do not close the login window when using it
  $('#nav-login-content').click(function(event){
    event.stopPropagation();
  });

  // minor UI tweaks so we don't have to override many views
  $('#filters').addClass('header_collapsible');
  $('#filters').siblings('fieldset').addClass('header_collapsible').attr('id', 'column_options');
  $('#filters div:first').css('overflow', 'hidden');
  $('#query_form_with_buttons').addClass('title-bar-extras');
  // FIXME positioning issues if placed in content
  $('body').append($('#context-menu'));
  $('#history h3').addClass('rounded-background');
  $('#history ul.details').addClass('journal-attributes');
  $('.issue p.author').after('<hr />');
  if($('body').hasClass('controller-issues') && $('body').hasClass('action-show')) {
    var orig_html = $('.controller-issues h2').html();
    var subject_html = $('.issue .subject h3').html();
    var new_html = subject_html + ' (' + orig_html + ')';
    $('.controller-issues h2').html(new_html);
    $('.issue .subject h3').hide();
    var $img = $('.issue img[width=50]:first').first();
    if($img.length == 1) {
      $('.issue .author').prepend($img);
    }
  }

});
