/*
        Trigger:        BooleanEvaluate
        @Author:        Anusha Akella
        @Created Date:  Mar 25th 2021
        @Description:   This is used in EstimationSummaryTriggerHandler in order to handle Document generation Triggering logic.
*/
public with sharing class BooleanEvaluate {


    private static final String ANDv = 'AND';
    private static final String ORv = 'OR';
    private static final String OPEN = '(';
    private static final String CLOSE = ')';

    private String expression;
    private Boolean[] values;
    private String finalExpression;

    public BooleanEvaluate(String expression, Boolean[] values){

        this.expression = expression.replaceAll('\\|\\|', 'OR').replaceAll('&&', 'AND');
        this.values = values;
        this.formatExpression();
    }

    public BooleanEvaluate(String expression, String[] arguments){

        expression = expression.replaceAll('\\|\\|', 'OR').replaceAll('&&', 'AND');
        this.expression = String.format( expression , arguments );
    }

    public boolean evaluate(){

        evaluate(this.expression);
        return evaluateExpression(this.finalExpression);

    }

    private void evaluate(String expression){

        if(!expression.contains(OPEN)){
            this.finalExpression = expression;
            return;
        }

        Integer indexOfOpen = -1;
        Integer indexOfClose = -1;

        String[] chars = expression.split('');
        for(Integer i = 0; i < chars.size(); i++){

            String singleChar = chars[i];

            if(singleChar == OPEN) {
                indexOfOpen = i;
                continue;
            }

            if(singleChar == CLOSE) {
                indexOfClose = i;
                break;
            }
        }

        String replace = expression.substring(indexOfOpen + 1 , indexOfClose);
        expression = expression.replace( OPEN + replace + CLOSE, String.valueOf( evaluateExpression(replace) ) );
        System.debug(replace);
        System.debug(expression);
        System.debug('########');
        evaluate(expression);

    }

    private Boolean evaluateExpression(String expression){

        Boolean result = false;
        for( String conj : expression.split(ORv) ){

            Boolean b = true;
            for( String single : conj.split(ANDv) ){
                b &= Boolean.valueOf(single.trim());
            }

            result |= b;
        }

        return result;

    }

    private void formatExpression(){
        system.debug('this.expression'+this.expression);
        String[] arguments = this.expression.split(' ');
        system.debug('arguments'+arguments);
        for(String arg : arguments){
            try{
                system.debug('is this entering');
                Integer index = Integer.valueOf(arg);
                system.debug('this.values'+this.values);
                this.expression = this.expression.replace(arg, String.valueOf(this.values[index - 1]));
                system.debug('this.expression 97'+this.expression);
            }catch(Exception e){
                continue;
            }
        }

        System.debug(this.expression);
    }
}