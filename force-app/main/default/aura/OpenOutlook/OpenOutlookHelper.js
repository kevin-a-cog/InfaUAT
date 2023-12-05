({
    makeTextFile : function(textbox) {
        var textFile = null;
        var data = new Blob([textbox], {type: 'text/plain'});
        
        if (textFile !== null) {
            window.URL.revokeObjectURL(textFile);
        }
        
        textFile = window.URL.createObjectURL(data);
        console.log('txt file'+textFile);
        return textFile;
    },
    populateTemplate : function(fetchInterlockRes,interlockId,component)
    {
        console.log('populateTemplate');
        var action3 = component.get( "c.fetchTemplate" );
        // action3.setParam("interlocktype",res);
        console.log('interlockType-->'+fetchInterlockRes.InterlockType);
        console.log('interlockId-->'+interlockId);
        var ccAddress=$A.get("$Label.c.Customer_Success_Email") ;
        console.log('ccAddress'+ ccAddress);
        
        action3.setParams({"interlocktype": fetchInterlockRes.InterlockType,"interlockId":interlockId});
        action3.setCallback(this, function(response) {
            console.log('iNSIDE CALL BACk 2===');
            
            var res2 = response.getReturnValue();
            
            console.log('res2-->'+JSON.stringify(res2));
            var subject = res2.Subject;
            console.log('subject-->'+subject);
            var emailBody = res2.HtmlValue;
            var templateName=res2.DeveloperName;
            var attach = 'path';
            var email='';
            console.log('templateName==='+templateName);
            //console.log('emailBody-->'+emailBody);
            
            if(fetchInterlockRes.InterlockType!=null && fetchInterlockRes.InterlockType!='' && fetchInterlockRes.InterlockType!='undefined')
            {
                if(fetchInterlockRes.InterlockType == 'JumpStart' ||fetchInterlockRes.InterlockType == 'Checkup' ||fetchInterlockRes.InterlockType== 'Renewal Rescue')
                {
                    console.log('Inside jumpstart interlock type-->'+fetchInterlockRes.InterlockType)
                    // email = 'adoptionsvcsapprove@informatica.com';
                    email=$A.get("$Label.c.Adoption_Services_Email") ;
                }
            }
            console.log('email value'+email);   
            if(subject!=null && subject!='' && subject!='undefined')
            {
                // subject.replace("â€“","");
                if(fetchInterlockRes.AccountRegion!=null && fetchInterlockRes.AccountRegion!='undefined')
                {
                    subject=subject.replace("{!Related_Opportunity_Plan__c.Account_Region_formula__c}",fetchInterlockRes.AccountRegion);
                }else
                {
                    subject=subject.replace("{!Related_Opportunity_Plan__c.Account_Region_formula__c}",'');
                }
                
                if(fetchInterlockRes.InterlockType!=null && fetchInterlockRes.InterlockType!='undefined')
                {
                    subject =subject.replace("{!Related_Opportunity_Plan__c.Interlock_Type__c}",'\r'+'  '+fetchInterlockRes.InterlockType);
                }else
                {
                    subject =subject.replace("{!Related_Opportunity_Plan__c.Interlock_Type__c}",''); 
                }
                if(fetchInterlockRes.AccountName!=null && fetchInterlockRes.AccountName!='undefined' )
                {
                    subject=subject.replace("{!Related_Opportunity_Plan__c.Account__c}", fetchInterlockRes.AccountName);
                }else
                {
                    subject=subject.replace("{!Related_Opportunity_Plan__c.Account__c}",'');
                }
                if(fetchInterlockRes.OpportunityNumber!=null && fetchInterlockRes.OpportunityNumber!='undefined')
                {
                    subject=subject.replace("{!Related_Opportunity_Plan__c.Opportunity_Number__c}", fetchInterlockRes.OpportunityNumber);
                }else
                {
                    subject=subject.replace("{!Related_Opportunity_Plan__c.Opportunity_Number__c}",'');
                }
                
            }
            if(emailBody!=null && emailBody!='' && emailBody!='undefined' )
            {
                //emailBody.replace("â€‹","");
                if(fetchInterlockRes.AccountName!=null &&  fetchInterlockRes.AccountName!='undefined' )
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Account__c}", fetchInterlockRes.AccountName+'\r\n \r\n');
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Account__c}",'\r\n \r\n');
                }
                 if(fetchInterlockRes.Id!=null &&  fetchInterlockRes.Id!='undefined' )
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Id}",fetchInterlockRes.Id);
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Id}",'\r\n \r\n');
                }
                
                
                if(fetchInterlockRes.InterlockType!=null && fetchInterlockRes.InterlockType!='undefined')
                {
                    emailBody =emailBody.replace("{!Related_Opportunity_Plan__c.Interlock_Type__c}",fetchInterlockRes.InterlockType);
                }else
                {
                    emailBody =emailBody.replace("{!Related_Opportunity_Plan__c.Interlock_Type__c}",''); 
                }
                if(fetchInterlockRes.Products!=null && fetchInterlockRes.Products!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Products__c}", fetchInterlockRes.Products+'\r\n \r\n');
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Products__c}",'\r\n \r\n');
                }
                if(fetchInterlockRes.OpportunityNumber!=null && fetchInterlockRes.OpportunityNumber!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Opportunity_Number__c}",fetchInterlockRes.OpportunityNumber);
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Opportunity_Number__c}",'\r\n \r\n');
                }
                if(fetchInterlockRes.SolutionType!=null && fetchInterlockRes.SolutionType!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Solution_Type__c}",fetchInterlockRes.SolutionType);
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Solution_Type__c}",'\r\n \r\n');
                }
                if(fetchInterlockRes.ExpectedStartDate!=null && fetchInterlockRes.ExpectedStartDate!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Expected_Start_Date__c}", fetchInterlockRes.ExpectedStartDate+'\r\n \r\n');
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Expected_Start_Date__c}",'\r\n \r\n');
                }
                if(fetchInterlockRes.FirstValue!=null && fetchInterlockRes.FirstValue!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.First_Value__c}", fetchInterlockRes.FirstValue); 
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.First_Value__c}", ''); 
                }
                if(fetchInterlockRes.ImplementationOwner!=null && fetchInterlockRes.ImplementationOwner!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Implementation_Owner__c}", fetchInterlockRes.ImplementationOwner+'\r\n \r\n');
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Implementation_Owner__c}",'\r\n \r\n');
                }
                if(fetchInterlockRes.SupportLevel!=null && fetchInterlockRes.SupportLevel!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Support_Level__c}", fetchInterlockRes.SupportLevel+'\r\n \r\n');
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Support_Level__c}", '\r\n \r\n');
                }
                if(fetchInterlockRes.SuccessPack!=null && fetchInterlockRes.SuccessPack!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Success_Pack__c}", fetchInterlockRes.SuccessPack+'\r\n \r\n');
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Success_Pack__c}",'\r\n \r\n');
                }
                if(fetchInterlockRes.OriginalOpportunityName!=null && fetchInterlockRes.OriginalOpportunityName!=undefined)
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Original_Opportunity__c}", fetchInterlockRes.OriginalOpportunityName+'\r\n \r\n'); 
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Original_Opportunity__c}",'\r\n \r\n'); 
                }
                if(fetchInterlockRes.OriginalOpportunityNumber!=null && fetchInterlockRes.OriginalOpportunityNumber!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Original_Opportunity_Number__c}", fetchInterlockRes.OriginalOpportunityNumber+'\r\n \r\n'); 
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Original_Opportunity_Number__c}",'\r\n \r\n');
                }
                if(fetchInterlockRes.ContractStartDate!=null && fetchInterlockRes.ContractStartDate!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Contract_StartDate__c}", fetchInterlockRes.ContractStartDate+'\r\n \r\n'); 
                } else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Contract_StartDate__c}", '\r\n \r\n'); 
                }
                if(fetchInterlockRes.ContractEndDate!=null && fetchInterlockRes.ContractEndDate!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Contract_EndDate__c}", fetchInterlockRes.ContractEndDate+'\r\n \r\n');  
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Contract_EndDate__c}", '\r\n \r\n');
                }
                if(fetchInterlockRes.OpportunityARR!=null && fetchInterlockRes.OpportunityARR!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Opportunity_ARR__c}", fetchInterlockRes.OpportunityARR+'\r\n \r\n');  
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Opportunity_ARR__c}", '\r\n \r\n'); 
                }
                if(fetchInterlockRes.Comments!=null && fetchInterlockRes.Comments!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Comments__c}", fetchInterlockRes.Comments+'\r\n \r\n');
                } else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Comments__c}",'\r\n \r\n');
                }
                if(fetchInterlockRes.ProjectName!=null && fetchInterlockRes.ProjectName!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Project_Name__c}",fetchInterlockRes.ProjectName+'\r\n \r\n');                               
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Project_Name__c}",'\r\n \r\n');
                }
                
                /*if( fetchInterlockRes.OwnerFullName!=null &&  fetchInterlockRes.OwnerFullName!='undefined')
                        {
                            //var emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.OwnerFullName}", fetchInterlockRes.OwnerFullName);
                        }
                        elseOwnerId	
                        {
                            //var emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.OwnerFullName}", fetchInterlockRes.OwnerFullName);
                        }*/
                if( fetchInterlockRes.OwnerFirstName!=null &&  fetchInterlockRes.OwnerFirstName!='undefined' && fetchInterlockRes.OwnerLastName!=null && fetchInterlockRes.OwnerLastName!='undefined')
                {
                    
                    var emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.OwnerFullName}", fetchInterlockRes.OwnerFirstName+ fetchInterlockRes.OwnerLastName);
                }
                else
                {
                    var emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.OwnerFullName}", '\r\n \r\n');
                }
                
                if(fetchInterlockRes.ThreadId!=null && fetchInterlockRes.ThreadId!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Thread_Id__c}", fetchInterlockRes.ThreadId+'\r\n \r\n'); 
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Thread_Id__c}", '\r\n \r\n');
                } 
                if(fetchInterlockRes.IPSPackage!=null && fetchInterlockRes.IPSPackage!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.IPS_Package__c}",fetchInterlockRes.IPSPackage); 
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.IPS_Package__c}",'\r\n \r\n'); 
                }
                if(fetchInterlockRes.IPSProject!=null && fetchInterlockRes.IPSProject!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.IPS_Project__c}",fetchInterlockRes.IPSProject);
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.IPS_Project__c}",'\r\n \r\n');
                }
                if(fetchInterlockRes.Opportunity!=null && fetchInterlockRes.Opportunity!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.OpportunityId__c}",fetchInterlockRes.Opportunity);
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.OpportunityId__c}",'\r\n \r\n');
                }
                /* if(fetchInterlockRes.Opportunity__c!=null && fetchInterlockRes.Opportunity__c!='undefined')
                            {
                                emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.OpportunityId__c}",fetchInterlockRes.Opportunity__c);
                            }else
                            {
                                emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.OpportunityId__c}",'\r\n \r\n');
                            }*/
                if(fetchInterlockRes.OldOrgOpportunityNumber!=null && fetchInterlockRes.OldOrgOpportunityNumber!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Old_Org_Opportunity_Number__c}",fetchInterlockRes.OldOrgOpportunityNumber);
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Old_Org_Opportunity_Number__c}",'\r\n \r\n');
                }
                
                /* if(fetchInterlockRes.AccountId__c!=null && fetchInterlockRes.AccountId__c!='undefined')
                            {
                                 emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.AccountId__c}",fetchInterlockRes.AccountId__c);
                            }elseAccount__c
                            {
                                 emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.AccountId__c}",'\r\n \r\n');
                            } */
                if(fetchInterlockRes.AccountId!=null && fetchInterlockRes.AccountId!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.AccountId__c}",fetchInterlockRes.AccountId);
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.AccountId__c}",'\r\n \r\n');
                } 
                if(fetchInterlockRes.LevelofRisk!=null && fetchInterlockRes.LevelofRisk!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Level_of_Risk__c}",fetchInterlockRes.LevelofRisk);
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Level_of_Risk__c}",'\r\n \r\n');
                }
                if(fetchInterlockRes.RenewalLikelihood!=null && fetchInterlockRes.RenewalLikelihood!='')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Renewal_Likelihood__c}",fetchInterlockRes.RenewalLikelihood);
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Renewal_Likelihood__c}",'\r\n \r\n');
                }
                if(fetchInterlockRes.DoWehaverenewalcommitment!=null && fetchInterlockRes.DoWehaverenewalcommitment!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Do_We_have_renewal_commitment__c}",fetchInterlockRes.DoWehaverenewalcommitment);
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Do_We_have_renewal_commitment__c}",'\r\n \r\n');
                }
                if(fetchInterlockRes.IsFirstYearRenewal!=null && fetchInterlockRes.IsFirstYearRenewal!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Is_First_Year_Renewal__c}",fetchInterlockRes.IsFirstYearRenewal);
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Do_We_have_renewal_commitment__c}",'\r\n \r\n');
                }
                if(fetchInterlockRes.LastContactDate!=null && fetchInterlockRes.LastContactDate!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Last_Contact_Date__c}",fetchInterlockRes.LastContactDate);
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Last_Contact_Date__c}",'\r\n \r\n');
                }
                /*   if(fetchInterlockRes.Contact__c!=null && fetchInterlockRes.Contact__c!='undefined')
                            {
                                emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Contact__c}",fetchInterlockRes.Contact__c);
                            }else
                            {
                                emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Contact__c}",'\r\n \r\n');
                            }*/
                if(fetchInterlockRes.ContactName!=null && fetchInterlockRes.ContactName!='undefined' )
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Contact__c}",fetchInterlockRes.ContactName);
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Contact__c}",'\r\n \r\n');
                }
                if(fetchInterlockRes.HighestRoleEngagedWith!=null && fetchInterlockRes.HighestRoleEngagedWith!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Highest_Role_Engaged_With__c}",fetchInterlockRes.HighestRoleEngagedWith);
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Highest_Role_Engaged_With__c}",'\r\n \r\n');
                }
                if(fetchInterlockRes.BusinessUseCase!=null && fetchInterlockRes.BusinessUseCase!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Business_Use_Case__c}",fetchInterlockRes.BusinessUseCase);
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Business_Use_Case__c}",'\r\n \r\n');
                }
                if(fetchInterlockRes.TechnicalUseCase!=null && fetchInterlockRes.TechnicalUseCase!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Technical_Use_Case__c}",fetchInterlockRes.TechnicalUseCase);
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Technical_Use_Case__c}",'\r\n \r\n');
                }
                if(fetchInterlockRes.AdoptedProducts!=null && fetchInterlockRes.AdoptedProducts!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Adopted_Products__c}",fetchInterlockRes.AdoptedProducts);
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Adopted_Products__c}",'\r\n \r\n');
                }
                if(fetchInterlockRes.NonAdopted!=null && fetchInterlockRes.NonAdopted!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Non_Adopted__c}",fetchInterlockRes.NonAdopted);
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Non_Adopted__c}",'\r\n \r\n');
                }
                if(fetchInterlockRes.Interested_products!=null && fetchInterlockRes.Interested_products!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Interested_products__c}",fetchInterlockRes.Interested_products);
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Interested_products__c}",'\r\n \r\n');
                }
                if(fetchInterlockRes.Adoption_Challenges!=null && fetchInterlockRes.Adoption_Challenges!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Adoption_Challenges__c}",fetchInterlockRes.Adoption_Challenges);
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Adoption_Challenges__c}",'\r\n \r\n');
                }
                if(fetchInterlockRes.CSMSummary!=null && fetchInterlockRes.CSMSummary!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.CSM_Summary__c}",fetchInterlockRes.CSMSummary);
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.CSM_Summary__c}",'\r\n \r\n');
                }
                if(fetchInterlockRes.AdditionalInformation!=null && fetchInterlockRes.AdditionalInformation!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Additional_Information__c}",fetchInterlockRes.AdditionalInformation);
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Additional_Information__c}",'\r\n \r\n');
                }
                if(fetchInterlockRes.RenewalDateformula!=null && fetchInterlockRes.RenewalDateformula!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Renewal_Date_formula__c}",fetchInterlockRes.RenewalDateformula);
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Renewal_Date_formula__c}",'\r\n \r\n');
                }
                if(fetchInterlockRes.Partnernameifany!=null && fetchInterlockRes.Partnernameifany!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Partner_name_if_any__c}",fetchInterlockRes.Partnernameifany);
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Partner_name_if_any__c}",'\r\n \r\n');
                }
                if(fetchInterlockRes.Keycustomercontact!=null && fetchInterlockRes.Keycustomercontact!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Key_customer_contact__c}",fetchInterlockRes.Keycustomercontact);
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Key_customer_contact__c}",'\r\n \r\n');
                }
                if(fetchInterlockRes.Primarychallenges!=null && fetchInterlockRes.Primarychallenges!='undefined')
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Primary_challenge_s__c}",fetchInterlockRes.Primarychallenges);
                }else
                {
                    emailBody=emailBody.replace("{!Related_Opportunity_Plan__c.Primary_challenge_s__c}",'\r\n \r\n');
                }
            }
            
            
            component.set("v.messageBody",emailBody);
            component.set("v.messagesubject",subject);
            //var toAddress='';
            var today = new Date();
            var txtval;
            var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
            
            
            
            console.log('fetchInterlockRes.IPS_Project_Manager_Email__c-->'+fetchInterlockRes.IPSProjectManagerEmail);
            console.log('email-->'+email);
            console.log('plan owner email-->'+fetchInterlockRes.PlanOwnerEmail);
            
            if(templateName!=null && templateName!='' && templateName!='undefined' && templateName=='SMG_HandOff_New')
            {
                console.log('templateName=SMG_HandOff_New');
                if(fetchInterlockRes.OpportunityOwnerEmail!=null && fetchInterlockRes.OpportunityOwnerEmail!='' && fetchInterlockRes.OpportunityOwnerEmail!='undefined')
                    // txtval = "To:"+ "<"+fetchInterlockRes.Opportunity_Owner_Email__c+'>;<'+email+';'+">"+"\n";
                    txtval = "To:"+ "<"+fetchInterlockRes.OpportunityOwnerEmail+'>;<'+fetchInterlockRes.PlanOwnerEmail+'>;'+"\n";
            }else
            {
                if(fetchInterlockRes.IPSProjectManagerEmail!=null && fetchInterlockRes.IPSProjectManagerEmail!='undefined' && email!=null && email!='undefined')
                {
                    console.log('inside 283');
                    txtval = "To:"+ "<"+fetchInterlockRes.IPSProjectManagerEmail+'>;<'+email+';<'+fetchInterlockRes.PlanOwnerEmail+'>;'+"\n";
                }
                else if((fetchInterlockRes.IPSProjectManagerEmail!=null && fetchInterlockRes.IPSProjectManagerEmail!='undefined') && (email==null || email=='undefined' ||email=='' ))
                {
                    console.log('inside 289');
                    txtval = "To:"+ "<"+fetchInterlockRes.IPSProjectManagerEmail+'>;<'+fetchInterlockRes.PlanOwnerEmail+'>;'+"\n";
                }
                
                    else if((email!=null && email!='undefined' && email!='') && (fetchInterlockRes.IPSProjectManagerEmail==null || fetchInterlockRes.IPSProjectManagerEmail=='undefined'))
                    {
                        console.log('inside 295');
                        txtval = "To:"+ "<"+email+">;<"+fetchInterlockRes.PlanOwnerEmail+'>;'+"\n";
                    }
            }
           
            if(ccAddress!=null && ccAddress!='undefined')
                txtval=txtval+"Cc:"+ccAddress+"\n";
            txtval = txtval + "Subject:" +subject + "\n";
            txtval = txtval + "X-Unsent: 1"+ "\n";
            txtval = txtval + "Content-Type: text/html" + "\n"; 
            txtval = txtval + "\n";
            txtval = txtval + "</p></p></n></n>";
            
            
            console.log('emailBody 235->'+emailBody);
            txtval = txtval + emailBody;
            txtval = txtval + "\n";
            
            console.log('txtval final -->'+txtval);
            var newlink = document.createElement('a');
            newlink.setAttribute('download', 'message.eml');
            newlink.setAttribute('href', 'showSignature(xyz)');
            newlink.setAttribute("type", "hidden");  
            newlink.setAttribute('id','downloadlink');
            
            newlink.href = this.makeTextFile(txtval);
            console.log('afer 247'+newlink.href);
            console.log(' 248'+JSON.stringify(newlink.href));
            
            
            document.body.appendChild(newlink);
            document.getElementById('downloadlink').click();
            component.set("v.downloaded","true");
            var toastEvent = $A.get("e.force:showToast");
            
            
            toastEvent.setParams({
                
                "duration":'7000',
                "type": 'success',
                "mode":"dismissible",
                "message": 'Downloaded Successfully. Please open downloaded Email to preview it'
            });
            
            toastEvent.fire();  
            
        });  
        $A.enqueueAction(action3);    
    }
    
})