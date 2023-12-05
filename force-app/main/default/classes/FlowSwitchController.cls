public with sharing class FlowSwitchController {
   
    @InvocableMethod(label='Recursion Check' description='Checks if flow is called recursively')
    public static List<Boolean> recursionCheck(List<String> flowName) {
        
        return new List<Boolean>{globalApexManager.avoidRecursion(flowName[0])};
    }
}