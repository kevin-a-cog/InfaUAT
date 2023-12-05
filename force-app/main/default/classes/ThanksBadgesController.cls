public class ThanksBadgesController {
    
    @AuraEnabled 
    public static List<WorkBadge> getAllBadgesGivenToMe(Id userRecordId) {
        List<WorkBadge> workbdg = [SELECT Definition.Name, Message, ImageUrl, Giver.Name 
                                   FROM WorkBadge
                                   WHERE RecipientId = :userRecordId];
        return workbdg;
    }
}