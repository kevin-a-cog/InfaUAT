/***************************************************************************
Class:         CassiniLatestInteractions 
@Author:        Anil Solanki
@Created Date:  12 March,2018
@Description:   Handler Class to be called from Cassini Interaction ConnectedApp.
*/
public class CassiniLatestInteractions implements Canvas.CanvasLifecycleHandler {
    
    public static globalApexManager GAM = new globalApexManager();
    
    public Set<Canvas.ContextTypeEnum> excludeContextTypes(){
        Set<Canvas.ContextTypeEnum> excluded = new Set<Canvas.ContextTypeEnum>();
        return excluded;
    }


    
    public void onRender(Canvas.RenderContext renderContext) {
        
        //Get the Application and Environment context from the RenderContext
        Canvas.ApplicationContext app = renderContext.getApplicationContext();
        Canvas.EnvironmentContext env = renderContext.getEnvironmentContext();
        //Getting the Current Record Id of Plan
        String envLocation = env.getLocationUrl();
        GAM.CreateLogs('CassiniLatestInteractions-->','onRender',env.getLocationUrl(),'ENV Location URL: ');
        
        String planRecordId ;
        if(env.getLocationUrl().CONTAINS(Label.CassiniInteractionURLIdentifier)){
            planRecordId = env.getLocationUrl().split(Label.CassiniInteractionURLIdentifier)[1].split('/')[0];
        }
        else{
            planRecordId = env.getLocationUrl().split(Label.NewCassiniInteractionsURLIdentifier)[1].split('/')[0];
        } 
        
        GAM.CreateLogs('CassiniLatestInteractions',' onRender',planRecordId,'planRecordId: ');
        
        URL url = new URL(app.getCanvasUrl());
        List<Plan__c> plan = new List<Plan__c>([Select Id , Account__r.New_Org_Account_Number__c from Plan__c where Id =:planRecordId]);
        String accountNumberCassini = '';
        if(plan.size() > 0 && !plan.IsEmpty()){
            accountNumberCassini = plan[0].Account__r.New_Org_Account_Number__c;
        }
       
       app.setCanvasUrlPath('/cassini-ui/#/latestinteractions/'+accountNumberCassini);
       GAM.CreateLogs('CassiniLatestInteractions', 'onRender',app.getCanvasUrl(),'URL: ');
        
        
      }
 }