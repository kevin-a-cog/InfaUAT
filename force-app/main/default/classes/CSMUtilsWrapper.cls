public class CSMUtilsWrapper {
    

    /** Wrapper for Plan Team Member creation */
    public class PlanTeam{

        public Id planId{get; set;}
        public Id userId{get; set;}
        public string userEmail{get; set;}
        public string role {get; set;}
        public string firstName {get; set;}
        public string lastName {get; set;}
        //public boolean enagagementTeamMember {get; set;}  
        public string source {get; set;}     
        
        public PlanTeam(){
            //enagagementTeamMember = false; 
        }
        
    }
}