({
    sendEmail: function(cmp, event, helper) {

        var getEmailsDE = cmp.get("c.getEmailsDE");
        getEmailsDE.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var p =response.getReturnValue();
                /*
                var a = document.createElement("a");
		        a.href = "mailto:"+ p +
		            "?subject=Test%20subject";
		        a.click();
		        $A.get("e.force:closeQuickAction").fire();
                */
                cmp.set('v.emails',p);
                //cmp.set('v.emailsCmd','mailto:' + p);
                 
                cmp.find("divEmails").getElement().select();
                document.execCommand( 'copy' );
		    }
        });
        $A.enqueueAction(getEmailsDE);  
    }
})