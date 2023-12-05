function redirectHelpLink()
    {
            var currurl = window.location.href;
            var posinternal = currurl.indexOf("KBSearch");
            var posKBExternal = currurl.indexOf("KBExternal");
            if (posinternal >= 0 && posKBExternal<=0 )
            window.open("/KBDocs/KB%20Search%20User%20Guide%20for%20Internal.pdf","mywindow");
            else
            window.open("/KBDocs/KB%20Search%20User%20Guide%20for%20Portal.pdf","mywindow");
    }


	function redirectLink()
    {
            var currurl = window.location.href;
            var posinternal = currurl.indexOf("KBSearch");
            var posKBExternal = currurl.indexOf("KBExternal");
            if (posinternal >= 0 && posKBExternal<=0 )
            window.location = "/KBSearch/default.aspx";
            else
            window.location = "/KBExternal/default.aspx";
    }
 function PrintPreview()
    { 	
        var win=window.open('about:blank','_blank');
        win.document.write('<html><body>' + document.getElementById('frame1').contentWindow.document.body.innerHTML+'</body></html>');
        win.document.writeln('<script>window.print();</' + 'script>');
        win.document.close();
    }
    function EmailPopup()
    { 	
        qs = window.location.search.substring(1);
        q = qs.split("&");
        var win = window.open('EmailExtended.aspx?' + qs, '_blank', 'scrollbars=yes,height=380px,width=400px');        
        win.document.close();
    }

    
   
    function RefreshPage()
    {
        document.getElementById("frame1").style.height= document.getElementById("frame1").contentWindow.document.body.scrollHeight+100 ;
        document.body.style.visibility="visible";
    }        
    function FeedbackVisibility()
    {
        //var ctrl=document.getElementById("fieldset1");        
        var ctrl1=document.getElementById("feedbackDiv");                        
        ctrl1.focus();
    }
    function SendMail()
    {
     	var o=document.getElementsByName('radio1');
 	    var l=document.getElementsByTagName('label'),i,j;
 	    
	    for(i=0;i<o.length;i++)
	    {	
	        if(o[i].checked)
	        {
	            for(j=0;j<l.length;j++)
	            {	
	                if(l[j].htmlFor == o[i].id)
	                {	              	                
	                    var mailto_link="mailto:" + document.getElementById('<%=HiddenField1.ClientID %>').value + "?subject=Feedback&body="+l[j].innerText +"%0D%0A"+document.getElementById("ta").innerText;
	                    var win = window.open(mailto_link,'emailWindow'); 
	                    return;
	                }
	            }
	        }            
        }
        alert("Please select a value in 'Did this article Help you' Section")
     }
     
     /* Panel extender scripts*/
     
      // not animated collapse/expand
function togglePannelStatus(content)
{
    var expand = (content.style.display=="none");
    content.style.display = (expand ? "block" : "none");
    toggleChevronIcon(content);
}

// current animated collapsible panel content
var currentContent = null;

function togglePannelAnimatedStatus(content, interval, step)
{
    // wait for another animated expand/collapse action to end
    if (currentContent==null)
    {
        currentContent = content;
        var expand = (content.style.display=="none");
        if (expand)
            content.style.display = "block";
        var max_height = content.offsetHeight;

        var step_height = step + (expand ? 0 : -max_height);
        toggleChevronIcon(content);
                
        // schedule first animated collapse/expand event
        content.style.height = Math.abs(step_height) + "px";
        setTimeout("togglePannelAnimatingStatus("
            + interval + "," + step
            + "," + max_height + "," + step_height + ")", interval);
    }
}

function togglePannelAnimatingStatus(interval,
    step, max_height, step_height)
{
    var step_height_abs = Math.abs(step_height);

    // schedule next animated collapse/expand event
    if (step_height_abs>=step && step_height_abs<=(max_height-step))
    {
        step_height += step;
        currentContent.style.height = Math.abs(step_height) + "px";
        setTimeout("togglePannelAnimatingStatus("
            + interval + "," + step
            + "," + max_height + "," + step_height + ")", interval);        
        currentContent.focus();
    }
    // animated expand/collapse done
    else
    {
        if (step_height_abs<step)
            currentContent.style.display = "none";
        currentContent.style.height = "";
        currentContent = null;
    }
}

// change chevron icon into either collapse or expand
function toggleChevronIcon(content)
{
    var chevron = content.parentNode
        .firstChild.childNodes[1].childNodes[0];
    var expand = (chevron.src.indexOf("expand.gif")>0);
    chevron.src = chevron.src
        .split(expand ? "expand.gif" : "collapse.gif")
        .join(expand ? "collapse.gif" : "expand.gif");
}