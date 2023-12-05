/**************************************************************************
JS file Name: header.js.
Author: Sathish Rajalingam
Company: Informatica
Date: 15-October-2020
Purpose: Holds all the function required KB Community Header.
Version: 1.0


Modificaiton History


  Tag       |  Date             |  Modified by              |  Jira reference   |   ChangesMade   
   1        |  24-Dec-2020      |  Sathish Rajalingam       |   I2RT-550        |   Removed unnecessary JS

***************************************************************************/


/*Global variable used across the application
 
*/

$(document).ready(function () {
		$(".bottom-header .level-2-item>span").hover(
			function() {
				$('.level-3').removeClass('maintain-hover');
				$(this).siblings('.level-3').addClass("maintain-hover");
			}
		);
		$(".bottom-header .dropdown").hover(
			function() {
				$('.level-3').removeClass('maintain-hover');
				$(this).children(".dropdown-menu").css("display", "block");
			},
			function() {
				$('.level-3').removeClass('maintain-hover');
				$(this).children(".dropdown-menu").css("display", "none");
			}
		);
		$("#mobileHamburgerIcon").click(function() {
			$(".mobile-dropdown").show();
			$(this).hide();
			$('#mobileNavCloseIcon').show();
			$('body').addClass('stop-scrolling');
		});
		$("#mobileNavCloseIcon").click(function() {
			$(".mobile-dropdown").hide();
			$(this).hide();
			$('#mobileHamburgerIcon').show();
			$('body').removeClass('stop-scrolling');
		});
		$(".nav-next-btn").click(function() {           
			if($(this).siblings('a').parent().parent().hasClass('mobile-dropdown-level-2') ||
				($(this).siblings('a').parent().parent().hasClass('mobile-dropdown-level-1') && 
				$(this).siblings('ul').hasClass('mobile-dropdown-level-2'))) {
				$(this).hide();
				$(this).siblings('a').css('display', 'none');
				let parentSiblings = $(this).parent().prevAll();
				for(let i=0; i < parentSiblings.length; i++) {
					$(parentSiblings[i]).css('display', 'none');
				}    
			}
			$(this).siblings('.mobile-dropdown-level-2').css('display', 'block');
			$(this).siblings('.mobile-dropdown-level-3').css('display', 'block');
			
		});

		$(".mobile-dropdown-level-3 .nav-prev-btn").click(function() { 
			$($(this).parent().parent().parent().children()[0]).css('display', 'inline');
			$($(this).parent().parent().parent().children()[1]).css('display', 'block');
			$(this).parent().parent().css('display', 'none');
			$(this).parent().parent().parent().css('display', 'block');
			let subparentSiblings = $(this).parent().parent().parent().prevAll();
			for(let i=0; i < subparentSiblings.length; i++) {
				$(subparentSiblings[i]).css('display', 'block');
			}
		});
		$(".nav-prev-btn.prev-btn-for-level1").click(function() { 
			$(this).parent().parent().css('display', 'none');
			let temp = $(this).parent().parent().siblings();
			for(let i=0; i < temp.length; i++) {
				$(temp[i]).css('display', 'inline-block');
			}
			$('body').removeClass('stop-scrolling');
			let subparentSiblings = $(this).parent().parent().parent().prevAll();
			for(let i=0; i < subparentSiblings.length; i++) {
				$(subparentSiblings[i]).css('display', 'inline-flex');
			}
		});
		$("#mobileUserIcon").click(function() {
			if($(".mobile-user-dropdown").css('display') == 'none') {
				$(".mobile-user-dropdown").show();
			}
			else  {
				$(".mobile-user-dropdown").hide();
			}  
		});
		$(".community-header-logo").click(function() {
			if($(".application-logo-dropdown").css('display') == 'none') {
				$(".application-logo-dropdown").show();
			}
			else  {
				$(".application-logo-dropdown").hide();
			} 
		});
		
		setTimeout(function () {
			try {
				let lastChildCount = $(".slds-grid.slds-gutters_small.full.cols-2.forcePageBlockSectionRow").last().children().length;
				for (let i = 0; i < lastChildCount; i++) {
					/*<1>*/
					//$($(".slds-grid.slds-gutters_small.full.cols-2.forcePageBlockSectionRow").last().children()[i]).children().css('border', 'none');
					/*</1>*/
				}
			} catch (ex) {
				console.log("Method : updateArticleBorder; Error :" + ex.description);
			}
			try {
				let count  = $(".test-id__field-value").length;
				for(let i = 0; i < count; i++) {
					if($($(".test-id__field-value")[i]).children()[0]) {
						if($($(".test-id__field-value")[i]).children()[0].innerText.trim() == "") {
							$($(".test-id__field-value")[i]).parent().parent().css('display', 'none');
						}
					}
					else {
						$($(".test-id__field-value")[i]).parent().parent().css('display', 'none');
					}
				}
				let checkCount = $(".forcePageBlockSectionRow").length;
				for(let i = 0; i < checkCount; i++) {
					if($($($($(".forcePageBlockSectionRow")[i]).children()[0]).children()[0]).css('display') == 'none') {
						if($($(".forcePageBlockSectionRow")[i]).children()[1]) {
							if($($($($(".forcePageBlockSectionRow")[i]).children()[1]).children()[0]).css('display') == 'none') {
								$($(".forcePageBlockSectionRow")[i]).css('display', 'none');
							}
						}
						else {
							$($(".forcePageBlockSectionRow")[i]).css('display', 'none')
						}
					}
				}
				if(($('span[title=Files]').siblings()[0] != undefined) && ($('span[title=Files]').siblings()[0].getAttribute('title') == "(0)")) {
					$('span[title=Files]').parent().parent().parent().parent().parent().parent().css('display', 'none');
				}
			} catch(ex) {
				console.log("Method: Hide Empty Fields. Error: " + ex.description);
			}
			
		}, 7500)
	});