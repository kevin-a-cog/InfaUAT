/*
******************************************************************************************************************
Change History
**************************************************************************************************************************
ModifiedBy          Date        Requested By        Description                                                   Tag
Anusha Akella       07/15/2022   KKA                Implement FLOOR, CEIL & ROUND functions for IPU Calculations <T14064>
Chandana Gowda      11/Jan/2022  SALESRT-14808      Enhance IPU calculation performance                          <T02>
*************************************************************************************************************************
*/
public without sharing class IPUE_CalculationUtils {

    public static final String delimiter = '~';

    ////////////////////////////////////////////////////////
    //  Compilation
    ////////////////////////////////////////////////////////

    // Public method that wraps all of the compilation functionality
    // Returns a delimited, postfix string representing the formula in Reverse Polish Notation
    public static String compileFormula(String formula) {
        if (String.isBlank(formula)) {
            return '';
        }
        List<Token> tokenFormula = parseToTokens(formula);
        List<Token> tokenPostfix = compileToPostfix(tokenFormula);
        String postfixString = toDelimitedString(tokenPostfix);
        return postfixString;
    }

    // Step 1 of the algorithm
    // Parses the string formula in to a list of Tokens
    private static List<Token> parseToTokens(String formula) {
        // Basic error handling
        if (String.isBlank(formula)) { return null; }

        List<Token> tokens = new List<Token>();
        List<String> charArray = formula.trim().split('');
        for (Integer index = 0; index < charArray.size(); index++) {
            // Ignore spaces between tokens
            while(index < charArray.size() && charArray[index].isWhitespace()) {
                index++;
            }

            String character = charArray[index];
            Boolean requiresMore = true;
            switch on character {
                // Idk why VSCode gets confused by the strings '+', '/', and '$', they're valid syntax
                when '+' {
                    tokens.add(new Token(TokenType.PLUS, character));
                }
                when '-' {
                    // Handle negative numbers nicely
                    Token prevToken;
                    if (!tokens.isEmpty()) {
                        prevToken = tokens[tokens.size() - 1];
                    } else {
                        prevToken = new Token(null, null);
                    }

                    switch on prevToken.type {
                        // When following a literal or end of block, should be subtraction
                        // TODO: Think about - after string
                        when VAR_LITERAL, NUMBER_LITERAL, STRING_LITERAL, RPAREN {
                            tokens.add(new Token(TokenType.MINUS, character));
                        }
                        // when PLUS, MINUS, TIMES, DIVIDE, LESS_THAN, LESS_THAN_EQUAL, GREATER_THAN, GREATER_THAN_EQUAL, LPAREN, COMMA {
                        // }
                        // When following an operator or start of block, should be the negative number indicator
                        when else {
                            index++;    // We need to look ahead at the number following it
                            // Look ahead for a number, variable, or function, skipping whitespace
                            while (index < charArray.size() && charArray[index].isWhitespace()) {
                                index++;
                            }
                            if (index >= charArray.size() || !(charArray[index].isAlphaNumeric() || charArray[index].equals('$') || charArray[index].equals('('))) {
                                throw new ParsingException('Unexpected character after "-": "' + (index >= charArray.size() ? 'end of input' : charArray[index]) + '"');
                            }
                            if (charArray[index].isNumeric()) {
                                // Handle -number
                                String numberInput = '-' + parseNumber(charArray, index);
                                index += numberInput.length();
                                tokens.add(new Token(TokenType.NUMBER_LITERAL, numberInput));
                                requiresMore = false;
                            } else if (charArray[index].equals('$')) {
                                // Handle -$var
                                index++;
                                String variableInput = '$' + parseVariable(charArray, index);
                                index += variableInput.length() - 1;
                                // Convert to -1 * $var
                                tokens.add(new Token(TokenType.NUMBER_LITERAL, '-1'));
                                tokens.add(new Token(TokenType.TIMES, '*'));
                                tokens.add(new Token(TokenType.VAR_LITERAL, variableInput));
                                requiresMore = false;
                            } else if (charArray[index].isAlpha()) {
                                // Handle -function
                                String functionName = parseFunction(charArray, index);
                                index += functionName.length();
                                // Convert to -1 * function
                                tokens.add(new Token(TokenType.NUMBER_LITERAL, '-1'));
                                tokens.add(new Token(TokenType.TIMES, '*'));
                                tokens.add(new Token(TokenType.FUNCTION, functionName));
                            } else if (charArray[index].equals('(')) {
                                // Convert to -1 * parenthesized expression
                                tokens.add(new Token(TokenType.NUMBER_LITERAL, '-1'));
                                tokens.add(new Token(TokenType.TIMES, '*'));
                                tokens.add(new Token(TokenType.LPAREN, '('));
                                index++;
                            } else {
                                // throw new ParsingException('Unexpected minus sign after operator: "' + prevToken.actualString + '"; must be followed by number, variable, or function');
                            }
                            index--;    // Correct for the extra lookahead
                        }
                    }
                }
                when '*' {
                    tokens.add(new Token(TokenType.TIMES, character));
                }
                when '/' {
                    tokens.add(new Token(TokenType.DIVIDE, character));
                }
                when '(' {
                    tokens.add(new Token(TokenType.LPAREN, character));
                }
                when ')' {
                    tokens.add(new Token(TokenType.RPAREN, character));
                    requiresMore = false;
                }
                when '<' {
                    if (index + 1 < charArray.size() && charArray[index+1].equals('=')) {
                        tokens.add(new Token(TokenType.LESS_THAN_EQUAL, '<='));
                        index++;
                    } else {
                        tokens.add(new Token(TokenType.LESS_THAN, character));
                    }
                }
                when '>' {
                    if (index + 1 < charArray.size() && charArray[index+1].equals('=')) {
                        tokens.add(new Token(TokenType.GREATER_THAN_EQUAL, '>='));
                        index++;
                    } else {
                        tokens.add(new Token(TokenType.GREATER_THAN, character));
                    }
                }
                when '=' {
                    tokens.add(new Token(TokenType.EQUALS, character));
                }
                when ',' {
                    tokens.add(new Token(TokenType.COMMA, character));
                }
                when '$' {
                    // Grab the whole variable name
                    index++;
                    String varName = '$' + parseVariable(charArray, index);
                    tokens.add(new Token(TokenType.VAR_LITERAL, varName));
                    index += varName.length() - 2;
                    requiresMore = false;
                }
                when '"' {
                    // Grab the whole string
                    index++;
                    String stringInput = '"' + parseString(charArray, index) + '"';
                    tokens.add(new Token(TokenType.STRING_LITERAL, stringInput));
                    index += stringInput.length() - 2;
                    requiresMore = false;
                }
                when else {
                    if (character.isNumeric()) {
                        // Grab the whole number
                        String numberInput = parseNumber(charArray, index);
                        tokens.add(new Token(TokenType.NUMBER_LITERAL, numberInput));
                        index += numberInput.length();
                        requiresMore = false;
                    } else if (character.isAlpha()) {
                        // Grab the full function name
                        String functionName = parseFunction(charArray, index);
                        tokens.add(new Token(TokenType.FUNCTION, functionName));
                        index += functionName.length();
                    } else {
                        throw new ParsingException('Unknown character encountered during parsing: "' + character + '"');
                    }
                    index--;
                }
            }
            if (requiresMore && index + 1 >= charArray.size()) {
                throw new ParsingException('Unexpected end of input');
            }
            checkPrev(tokens);
        }
        return tokens;
    }

    // Utilities for parsing arbitrary multi-character tokens
    private static String parseNumber(List<String> charArray, Integer index) {
        // By the time this method is called, we've already checked that there's at least 1 numeric character up front
        String numberInput = '';
        while (index < charArray.size() && (charArray[index].isNumeric() || charArray[index].equals('.'))) {
            numberInput = numberInput + charArray[index];
            index++;
        }
        if (numberInput.countMatches('.') > 1) {
            throw new ParsingException('Invalid number: "' + numberInput + '"');
        }
        return numberInput;
    }

    private static String parseVariable(List<String> charArray, Integer index) {
        String textInput = '';
        while (index < charArray.size() && (charArray[index].isAlphaNumeric() || charArray[index].equals('_'))) {
            textInput = textInput + charArray[index];
            index++;
        }
        return textInput;
    }

    private static String parseFunction(List<String> charArray, Integer index) {
        String functionName = '';
        while (index < charArray.size() && charArray[index].isAlphaNumeric()) {
            functionName = functionName + charArray[index];
            index++;
        }
        String functionNameLower = functionName.toLowerCase();
        if (functionNamesToParamCounts.containsKey(functionNameLower)) {
            // Look ahead for a paren, skipping whitespace
            while (index < charArray.size() && charArray[index].isWhitespace()) {
                index++;
            }
            if (index >= charArray.size() || !charArray[index].equals('(')) {
                throw new ParsingException('Function "' + functionName + '" must be followed by parenthesis');
            }
            // move index back down so that we can process the paren separately
            index--;

        } else {
            throw new ParsingException('Unknown function: "' + functionName + '"');
        }
        return functionNameLower;
    }

    private static String parseString(List<String> charArray, Integer index) {
        String literal = '';
        while (index < charArray.size() && !charArray[index].equals('"')) {
            literal = literal + charArray[index];
            index++;
        }
        if (index >= chararray.size()) {
            throw new ParsingException('String missing close quote: ' + literal);
        }
        return literal;
    }

    // Implements small amount of look-behind to make sure formulas are valid
    private static void checkPrev(List<Token> tokens) {
        if (tokens.size() < 2) {
            return;
        }
        Token last = tokens[tokens.size() - 1];
        Token prev = tokens[tokens.size() - 2];
        switch on prev.type {
            when PLUS, MINUS, TIMES, DIVIDE, LESS_THAN, LESS_THAN_EQUAL, GREATER_THAN, GREATER_THAN_EQUAL, EQUALS {
                // After operator, there should come a number, variable, left paren, or function
                if (!isAfterOperator(last)) {
                    throw new ParsingException('After ' + prev.actualString + ' should come number, variable, left parenthesis, or function');
                }
            }
            when RPAREN, NUMBER_LITERAL, STRING_LITERAL, VAR_LITERAL {
                if (!isAfterLiteral(last)) {
                    throw new ParsingException('After ' + prev.actualString +  ' should come operator, comma, right parenthesis, or end of formula');
                }
            }
            when else {
                return;
            }
        }
    }

    // Utilities to support the look-behind
    private static Boolean isAfterLiteral(Token t) {
        return afterLiteral.contains(t.type);
    }

    private static final Set<TokenType> afterLiteral = new Set<TokenType> {
        TokenType.PLUS,
        TokenType.MINUS,
        TokenType.TIMES,
        TokenType.DIVIDE,
        TokenType.EQUALS,
        TokenType.LESS_THAN,
        TokenType.LESS_THAN_EQUAL,
        TokenType.GREATER_THAN,
        TokenType.GREATER_THAN_EQUAL,
        TokenType.RPAREN,
        TokenType.COMMA
    };

    private static Boolean isAfterOperator(Token t) {
        return afterOperator.contains(t.type);
    }

    private static final Set<TokenType> afterOperator = new Set<TokenType> {
        TokenType.NUMBER_LITERAL,
        TokenType.STRING_LITERAL,
        TokenType.VAR_LITERAL,
        TokenType.LPAREN,
        TokenType.FUNCTION
    };

    // Step 2 of the algorithm: the fun part. Modified shunting-yard algorithm
    // Iterate over the list of tokens
    //  If you find a literal, put it on the output list
    //  If you find an operator, look at the operator stack
    //      Pop any operators with higher precedence and add them to the output list
    //      Push it onto the operator stack
    //  If you find a left paren, push it onto the stack
    //  If you find a right paren
    //      Pop from the operator stack, adding to the output list until you pop a left paren, counting commas
    //      If the top of the operator stack is a function with fixed number of parameters, push that onto the output list as well
    //      If the top of the operator stack is a function with variable number of parameters, push the number of commas+1 onto the output stack as a token, then push the function
    // When there are no tokens of input left, pop the stack onto the output list until it's empty
    private static List<Token> compileToPostfix(List<Token> formula) {
        TokenStack operatorStack = new TokenStack();
        List<Token> outputList = new List<Token>();
        Integer commaCounter = 0;
        Boolean hasParam = true;
        for (Integer index = 0; index < formula.size(); index++) {
            Token t = formula[index];
            switch on t.type {
                when VAR_LITERAL, NUMBER_LITERAL, STRING_LITERAL {
                    hasParam = true;
                    outputList.add(t);
                }
                when PLUS, MINUS, TIMES, DIVIDE, LESS_THAN, GREATER_THAN, LESS_THAN_EQUAL, GREATER_THAN_EQUAL, EQUALS, COMMA {
                    Integer currentPrecedence = operatorPrecedence.get(t.type);
                    for (Integer nextPrecedence = operatorPrecedence.get(operatorStack.peek()?.type); !operatorStack.isEmpty() && nextPrecedence > currentPrecedence; nextPrecedence = operatorPrecedence.get(operatorStack.peek()?.type)) {
                        outputList.add(operatorStack.pop());
                    }
                    operatorStack.push(t);
                }
                when LPAREN {
                    hasParam = false;
                    operatorStack.push(t);
                }
                when FUNCTION {
                    operatorStack.push(t);
                }
                when RPAREN {
                    Token operator;
                    for (operator = operatorStack.pop(); operator.type != TokenType.LPAREN && !operatorStack.isEmpty(); operator = operatorStack.pop()) {
                        if (operator.type == TokenType.COMMA) {
                            commaCounter++;
                        } else {
                            outputList.add(operator);
                        }
                    }
                    if (operator.type != TokenType.LPAREN) {
                        throw new ParsingException('Mismatched parenthesis');
                    }
                    if (operatorStack.peek()?.type == TokenType.FUNCTION) {
                        Token func = operatorStack.pop();
                        Integer paramCount = functionNamesToParamCounts.get(func.actualString);
                        Integer actualParams = hasParam ? commaCounter + 1 : 0;
                        if (paramCount >= 0) {
                            if (actualParams != paramCount) {
                                throw new ParsingException('Function "' + func.actualString + '" expects ' + paramCount + ' parameters, received ' + actualParams);
                            }
                        } else if (paramCount < 0) {
                            // Encodes variable number of parameters
                            outputList.add(new Token(TokenType.NUMBER_LITERAL, stringValue(actualParams)));
                        }
                        outputList.add(func);
                    }
                    hasParam = true;
                    commaCounter = 0;
                }
                when else {
                    throw new ParsingException('Unknown error encountered during parsing');
                }
            }
        }
        while (!operatorStack.isEmpty()) {
            Token t = operatorStack.pop();
            if (t.type == TokenType.LPAREN) {
                throw new ParsingException('Mismatched parenthesis');
            }
            outputList.add(t);
        }
        return outputList;
    }

    // Step 3 of the algorithm: convert to an easy-to-parse string representation
    // Just insert delimiters between the actual token strings; identifying them later will be easy
    private static String toDelimitedString(List<Token> formula) {
        List<String> tokenStrings = new List<String>();
        for (Token t : formula) {
            tokenStrings.add(t.actualString);
        }
        return String.join(tokenStrings, delimiter);
    }

    // Public utility method to extract all variable names from a compiled, delimited formula
    // Used by trigger handler to establish Calculation Schedule Members
    public static Set<String> extractVarNames(String delimitedFormula) {
        Set<String> names = new Set<String>();
        for (String s : delimitedFormula.split(delimiter)) {
            if (s.startsWith('$')) {
                names.add(s.substring(1));  // Cut off the leading '$'
            }
        }
        return names;
    }

    public class ParsingException extends Exception {}

    ////////////////////////////////////////////////////////
    // Evaluation
    ////////////////////////////////////////////////////////

    // transform variables
    // query the related consumption schedules and rates
    // for each schedule that has the computed flag
    //     recursively call the calculation method
    //     add the response to map from output id => answer
    // do the actual calculation
    // add that to the map
    // return the map

    // Global data representing already discovered values
    public static Map<Id, Map<String, Decimal>> computedValuesByCalcId = new Map<Id, Map<String, Decimal>>();
    private static Map<Id, ConsumptionSchedule> schedulesByCalcId = new Map<Id, ConsumptionSchedule>();

    //Added the parameter unfilledSectionCalculation - holds the calculations for unfilled sections - <T02>
    public static Map<Id, Map<String,Decimal>> evaluateCalculation(Calculation__c calculation, List<Estimation_Output__c> variables,Map<Id, Map<String, Decimal>> unfilledSectionCalculation) {

        // If it's already been calculated, just return
        if (computedValuesByCalcId.containsKey(calculation.Id)) {
            return computedValuesByCalcId;
        }

        /******** Initial setup stuff to only do at the top level ********/

        // Map where key = Consumption Schedule Name, value = List of Tokens (created from Estimation Outputs) associated to the Schedule
        Map<String, List<Token>> tokenListByScheduleName = transformVariables(variables);
        // Map where key = Calculation Id, value = related Consumption Schedule
        Map<String, ConsumptionSchedule> schedulesByName = queryAllSchedules(tokenListByScheduleName, calculation);

        // Recursive method to calculate answers
        //Added the parameter unfilledSectionCalculation - <T02>
        return evaluateRecursive(calculation, tokenListByScheduleName, schedulesByName, unfilledSectionCalculation);
    }

    // Step 0: Modify the input data so that we can work with it easily
    private static Map<String, List<Token>> transformVariables(List<Estimation_Output__c> inputs) {

        Map<String, List<Token>> tokenListByScheduleName = new Map<String, List<Token>>();
        
        // Loop through Estimation Outputs and convert to Tokens to be used later in calculations
        for (Estimation_Output__c var : inputs) {
            
            List<Token> tokenList = new List<Token>();
            Token token;

            // Don't add table record - it will be added with children
            if (var.Estimation_Schedule__r.Data_Type__c == IPUE_CONSTANTS.TABLE_ELASTIC) {
                continue;
            }

            // Create Token for Estimation Output record
            try {
                token = new Token(TokenType.NUMBER_LITERAL, stringValue(decimalValue(var.User_Value__c)));
            } catch(TypeException e) {
                token = new Token(TokenType.STRING_LITERAL, var.User_Value__c);
            }

            // If the Output is part of an Elastic Table, add the row number to the Token
            if (var.Parent_Estimation_Schedule__r.Data_Type__c == IPUE_CONSTANTS.TABLE_ELASTIC && var.Row_Number__c > 0) {
                
                token.rowNumber = var.Row_Number__c;
                token.columnNumber = var.Column_Number__c;

                // Get existing List of Tokens associated to the Estimation Schedule
                if (tokenListByScheduleName.containsKey(var.IPUE_ScheduleName__c)) {
                    tokenList = tokenListByScheduleName.get(var.IPUE_ScheduleName__c);
                }
            
                Token parentToken;

                // If the Parent Schedule (i.e. Table) has already been added, find the associated Token
                if (tokenListByScheduleName.containsKey(var.Parent_Estimation_Schedule__r.Name)) {
                    parentToken = tokenListByScheduleName.get(var.Parent_Estimation_Schedule__r.Name)[0]; // Return first one
                // Otherwise, create a new Token to represent the Parent
                } else {
                    parentToken = new Token(TokenType.STRING_LITERAL, '');
                }

                // Add the children names to the Parent Token to be used later in the aggregate functions
                parentToken.children.add(var.IPUE_ScheduleName__c);
                // Add the updated parent token to the Token Map
                tokenListByScheduleName.put(var.Parent_Estimation_Schedule__r.Name, new List<Token>{parentToken});
            } 

            tokenList.add(token);
            tokenListByScheduleName.put(var.IPUE_ScheduleName__c, tokenList);

        }

        return tokenListByScheduleName;
    }

    // Step 0.1: Query the related schedule data for use by range functions
    private static Map<String, ConsumptionSchedule> queryAllSchedules(Map<String, List<Token>> inputs, Calculation__c calc) {
        Map<String, ConsumptionSchedule> schedulesByName = new Map<String, ConsumptionSchedule>();
        Set<String> allNames = getRelatedScheduleNames(calc);
        allNames.addAll(inputs.keySet());
        for (ConsumptionSchedule schedule : [
            SELECT Id, Name, Data_Type__c, Active__c, IPU_Calculation__c, IPU_Calculation__r.IPUE_PostfixFormula__c, IPU_Calculation__r.Id, 
            IPU_Calculation__r.Name,
                (
                    SELECT Id, IPU_Lower_Bound__c, IPU_Upper_Bound__c, Outcome__c
                    FROM ConsumptionRates
                    ORDER BY IPU_Lower_Bound__c ASC
                )
            FROM ConsumptionSchedule
            WHERE Name IN :allNames
        ]) {
            schedulesByName.put(schedule.name, schedule);
            if (schedule.Data_Type__c == IPUE_CONSTANTS.CALCULATED) {
                schedulesByCalcId.put(schedule.IPU_Calculation__c, schedule);
            }
        }
        return schedulesByName;
    }

    private static Set<String> getRelatedScheduleNames(Calculation__c calc) {
        Set<String> names = new Set<String>();
        for (String s : calc.IPUE_PostfixFormula__c.split(delimiter)) {
            if (s.startsWith('$')) {
                names.add(s.substring(1));
            }
        }
        return names;
    }

    // The recursive workhorse method:
    //  Looks through the formula for any variables that represent calculations
    //  Recursively calculates those calculations
    //  Calculates the formula with the newly-found inputs
    //  Added the parameter unfilledSectionCalculation - holds the calculations for unfilled sections - <T02>
    private static Map<Id, Map<String, Decimal>> evaluateRecursive(Calculation__c calculation, Map<String, List<Token>> tokenListByScheduleName, Map<String, ConsumptionSchedule> schedulesByName, Map<Id, Map<String, Decimal>> unfilledSectionCalculation) {
        
        // If it's already been calculated, just return
        if (computedValuesByCalcId.containsKey(calculation.Id)) {
            return computedValuesByCalcId;
        }

        if(unfilledSectionCalculation.containsKey(calculation.Id)){
            //If the section is not filled do not evaluate the calculation - <T02>
            return new Map<Id, Map<String, Decimal>>{calculation.Id => unfilledSectionCalculation.get(calculation.Id)};
        }

        // 1. Parse the formula into tokens for easy reading
        List<Token> postfixFormula = quickParse(calculation.IPUE_PostfixFormula__c);

        // 1.5 Ensure that we have all of the necessary rate card info
        schedulesByName = queryAdditionalSchedules(calculation, schedulesByName);

        // 2. Recursively evaluate any nested calculations
        for (Integer i = 0; i < postFixFormula.size(); i++) {

            Token t = postFixFormula[i];

            if (
                t.type == TokenType.VAR_LITERAL // The token is a variable
                && schedulesByName.get(t.actualString)?.Data_Type__c == IPUE_CONSTANTS.CALCULATED // It represents an equation
                && schedulesByName.get(t.actualString)?.Active__c   // It's active
                && !(i+1 < postFixFormula.size() && isRangeFunction(postfixFormula[i+1]))  // It's not just being used as a rate card
            ) {

                Map<Id, Map<String, Decimal>> newValuesByCalcId = evaluateRecursive(schedulesByName.get(t.actualString).IPU_Calculation__r, tokenListByScheduleName, schedulesByName, unfilledSectionCalculation);

                // Track calculated values
                computedValuesByCalcId.putAll(newValuesByCalcId);

                // Loop through any new Calculations and update the tokenListByScheduleName Map
                for (Id calcId : newValuesByCalcId.keySet()) {

                    Map<String, Decimal> answerMap = newValuesByCalcId.get(calcId);
                    String scheduleName = schedulesByCalcId.get(calcId).Name;
                    List<Token> tokenList = new List<Token>();

                    for (String key : answerMap.keySet()) {

                        Token token = new Token(TokenType.NUMBER_LITERAL, stringValue(answerMap.get(key)));
                        
                        try {
                            token.rowNumber = Decimal.valueOf(key);
                        } catch (Exception e){
                            // do nothing
                        }

                        tokenList.add(token);
                    }
    
                    tokenListByScheduleName.put(scheduleName, tokenList);
                    
                }
            }
        }

        // 3. Evaluate the formula with all of the new data
        try {

            Map<String, Decimal> resultByKey = evaluateWithVariables(postfixFormula, tokenListByScheduleName, schedulesByName);  
            computedValuesByCalcId.put(calculation.Id, resultByKey);
            return computedValuesByCalcId;

        } catch(Exception e) {
            System.debug('Exception: ' + e);
            System.debug('Exception message: ' + e.getMessage());
            System.debug('Exception stack trace: ' + e.getStackTraceString());
            System.debug('Exception cause: ' + e.getCause());
            throw new EvaluationException('Error evaluating calculation "' + calculation.Name + '": ' + e.getMessage());
        }
    }

    // Step 1: Re-parse the formula from a string into tokens
    // Already been checked for errors, so we don't check here
    private static List<Token> quickParse(String formula) {
        List<String> split = formula.split(delimiter);
        List<Token> tokens = new List<Token>();
        for (String s : split) {
            String firstChar = s.substring(0,1);
            switch on firstChar {
                when '+' {
                    tokens.add(new Token(TokenType.PLUS, firstChar));
                }
                when '-' {
                    // Allow for negative numbers and subtraction symbols
                    if (s.length() > 1) {
                        tokens.add(new Token(TokenType.NUMBER_LITERAL, s));
                    } else {
                        tokens.add(new Token(TokenType.MINUS, firstChar));
                    }
                }
                when '*' {
                    tokens.add(new Token(TokenType.TIMES, firstChar));
                }
                when '/' {
                    tokens.add(new Token(TokenType.DIVIDE, firstChar));
                }
                when '(' {
                    tokens.add(new Token(TokenType.LPAREN, firstChar));
                }
                when ')' {
                    tokens.add(new Token(TokenType.RPAREN, firstChar));
                }
                when '<' {
                    if (s.length() > 1) {
                        tokens.add(new Token(TokenType.LESS_THAN_EQUAL, '<='));
                    } else {
                        tokens.add(new Token(TokenType.LESS_THAN, firstChar));
                    }
                }
                when '>' {
                    if (s.length() > 1) {
                        tokens.add(new Token(TokenType.GREATER_THAN_EQUAL, '>='));
                    } else {
                        tokens.add(new Token(TokenType.GREATER_THAN, firstChar));
                    }
                }
                when '=' {
                    tokens.add(new Token(TokenType.EQUALS, firstChar));
                }
                when ',' {
                    tokens.add(new Token(TokenType.COMMA, firstChar));
                }
                when '$' {
                    // Drop the "$" and just keep the name
                    tokens.add(new Token(TokenType.VAR_LITERAL, s.substring(1)));
                }
                when '"' {
                    // Cut off the leading and trailing quotes
                    tokens.add(new Token(TokenType.STRING_LITERAL, s.substring(1, s.length() - 1)));
                }
                when else {
                    if (firstChar.isNumeric()) {
                        tokens.add(new Token(TokenType.NUMBER_LITERAL, s));
                    } else if (firstChar.isAlpha()) {
                        tokens.add(new Token(TokenType.FUNCTION, s));
                    } else {
                        throw new EvaluationException('Unknown error parsing formula');
                    }
                }
            }
        }
        return tokens;
    }

    // Step 1.5: Find additional variables as necessary
    private static Map<String, ConsumptionSchedule> queryAdditionalSchedules(Calculation__c calc, Map<String, ConsumptionSchedule> schedulesByName) {
        Set<String> missingNames = new Set<String>();
        for (String s : calc.IPUE_PostfixFormula__c.split(delimiter)) {
            if (s.startsWith('$') && !schedulesByName.keySet().contains(s.substring(1))) {
                missingNames.add(s.substring(1));
            }
        }
        if (!missingNames.isEmpty()) {
            for (ConsumptionSchedule schedule : [
                SELECT Id, Name, Data_Type__c, Active__c, IPU_Calculation__c, IPU_Calculation__r.IPUE_PostfixFormula__c, IPU_Calculation__r.Id, 
                    (
                        SELECT Id, IPU_Lower_Bound__c, IPU_Upper_Bound__c, Outcome__c
                        FROM ConsumptionRates
                        ORDER BY IPU_Lower_Bound__c ASC
                    )
                FROM ConsumptionSchedule
                WHERE Name IN :missingNames
            ]) {
                schedulesByName.put(schedule.name, schedule);
                schedulesByCalcId.put(schedule.IPU_Calculation__c, schedule);
            }
        }
        return schedulesByName;
    }

    // By this time, we just need the formula to do its calculations
    // Step 3: Evaluate using stacks
    private static  Map<String, Decimal> evaluateWithVariables(List<Token> formula, Map<String, List<Token>> tokenListByScheduleName, Map<String, ConsumptionSchedule> schedulesByName) {
        
        Map<String, Decimal> returnMap = new Map<String, Decimal>();
        // Prep data so that only the following is performed per row
        Map<String, Map<String, Token>> tokenMapByKey = new Map<String, Map<String, Token>>();

        /***** Reorganize data to build Map where tokens are organized by rows *******/
        for (String scheduleName : tokenListByScheduleName.keySet()) {

            // Loop through all tokens associated to the same Estimation Schedule
            for (Token token : tokenListByScheduleName.get(scheduleName)) {

                String key;

                if (token.rowNumber != null) {
                    key = String.valueOf(token.rowNumber);
                } else {
                    key = IPUE_CONSTANTS.DEFAULT_KEY;
                }

                Map<String, Token> tokenByScheduleName = new Map<String, Token>();
                if (tokenMapByKey.containsKey(key)) {
                    tokenByScheduleName = tokenMapByKey.get(key);
                }
                tokenByScheduleName.put(scheduleName, token);
                tokenMapByKey.put(key, tokenByScheduleName);
            }
        }

        /********* For every set of unique data (i.e. Default, Row 1, Row 2, etc.) ******/
        for (String uniqueKey : tokenMapByKey.keySet()) {

            // Find Tokens unique to the data set
            Map<String, Token> tokenByScheduleName = tokenMapByKey.get(uniqueKey);
            TokenStack paramStack = new TokenStack();

            // Evaluate formula
            for (Token t : formula) {

                switch on t.type {
                    when NUMBER_LITERAL, VAR_LITERAL, STRING_LITERAL {
                        paramStack.push(t);
                    }
                    // By process of elimination, at this point it MUST be an operator
                    when PLUS {

                        Decimal b = decimalValue(paramStack.pop(), tokenByScheduleName);
                        Decimal a = decimalValue(paramStack.pop(), tokenByScheduleName);
                        Decimal result;
                        if (a == null) {
                            result = b;
                        } else if (b == null) {
                            result = a;
                        } else {
                            result = a + b;
                        }
                        paramStack.push(new Token(TokenType.NUMBER_LITERAL, stringValue(result)));
                    }
                    when MINUS {
                        Decimal b = decimalValue(paramStack.pop(), tokenByScheduleName);
                        Decimal a = decimalValue(paramStack.pop(), tokenByScheduleName);
                        Decimal result;
                        if (a == null) {
                            result = -b;
                        } else if (b == null) {
                            result = a;
                        } else {
                            result = a - b;
                        }
                        paramStack.push(new Token(TokenType.NUMBER_LITERAL, stringValue(result)));
                    }
                    when TIMES {
                        Decimal b = decimalValue(paramStack.pop(), tokenByScheduleName);
                        Decimal a = decimalValue(paramStack.pop(), tokenByScheduleName);
                        Decimal result;
                        if (a == null || b == null) {
                            result = null;
                        } else {
                            result = a * b;
                        }
                        paramStack.push(new Token(TokenType.NUMBER_LITERAL, stringValue(result)));
                    }
                    when DIVIDE {
                        Decimal b = decimalValue(paramStack.pop(), tokenByScheduleName);
                        Decimal a = decimalValue(paramStack.pop(), tokenByScheduleName);
                        Decimal result;
                        if (a == null) {
                            result = null;
                        } else if (b == null) {
                            // throw new EvaluationException('Cannot divide by null');
                            result = null;
                        } else {
                            result = a / b;
                        }
                        paramStack.push(new Token(TokenType.NUMBER_LITERAL, stringValue(result)));
                    }
                    when LESS_THAN {
                        Decimal b = decimalValue(paramStack.pop(), tokenByScheduleName);
                        Decimal a = decimalValue(paramStack.pop(), tokenByScheduleName);
                        Boolean result;
                        if (a == null && b == null) {
                            result = false;
                        } else if (a == null) {
                            result = true;
                        } else if (b == null) {
                            result = false;
                        } else {
                            result = a < b;
                        }
                        paramStack.push(new Token(TokenType.NUMBER_LITERAL, stringValue(result)));
                    }
                    when LESS_THAN_EQUAL {
                        Decimal b = decimalValue(paramStack.pop(), tokenByScheduleName);
                        Decimal a = decimalValue(paramStack.pop(), tokenByScheduleName);
                        Boolean result;
                        if (a == null && b == null) {
                            result = true;
                        } else if (a == null) {
                            result = true;
                        } else if (b == null) {
                            result = false;
                        } else {
                            result = a <= b;
                        }
                        paramStack.push(new Token(TokenType.NUMBER_LITERAL, stringValue(result)));
                    }
                    when GREATER_THAN {
                        Decimal b = decimalValue(paramStack.pop(), tokenByScheduleName);
                        Decimal a = decimalValue(paramStack.pop(), tokenByScheduleName);
                        Boolean result;
                        if (a == null && b == null) {
                            result = false;
                        } else if (a == null) {
                            result = false;
                        } else if (b == null) {
                            result = true;
                        } else {
                            result = a > b;
                        }
                        paramStack.push(new Token(TokenType.NUMBER_LITERAL, stringValue(result)));
                    }
                    when GREATER_THAN_EQUAL {
                        Decimal b = decimalValue(paramStack.pop(), tokenByScheduleName);
                        Decimal a = decimalValue(paramStack.pop(), tokenByScheduleName);
                        Boolean result;
                        if (a == null && b == null) {
                            result = true;
                        } else if (a == null) {
                            result = false;
                        } else if (b == null) {
                            result = true;
                        } else {
                            result = a >= b;
                        }
                        paramStack.push(new Token(TokenType.NUMBER_LITERAL, stringValue(result)));
                    }
                    when EQUALS {
                        Object b = objectValue(paramStack.pop(), tokenByScheduleName);
                        Object a = objectValue(paramStack.pop(), tokenByScheduleName);
                        // "==" handles nulls by itself
                        paramStack.push(new Token(TokenType.NUMBER_LITERAL, stringValue(a == b)));
                    }
                    when FUNCTION {
                        switch on t.actualString {
                            when 'if' {
                                Object elseVal = objectValue(paramStack.pop(), tokenByScheduleName);
                                Object thenVal = objectValue(paramStack.pop(), tokenByScheduleName);
                                Boolean ifCond = Boolean.valueOf(paramStack.pop().actualString);
                                paramStack.push(new Token(TokenType.NUMBER_LITERAL, stringValue(ifCond ? thenVal : elseVal)));
                            }
                            when 'count' {
                                Integer paramCount = Integer.valueOf(paramStack.pop().actualString);
                                List<Decimal> params = new List<Decimal>();
                                Integer count = 0;
                                for (Integer i = 0; i < paramCount; i++) {
                                    Token param = paramStack.pop();
                                    Boolean isValidNumber = param.type == TokenType.NUMBER_LITERAL && !String.isBlank(param.actualString);
                                    Boolean isValidString = param.type == TokenType.STRING_LITERAL && !String.isBlank(param.actualString);
                                    Boolean isValidVar = param.type == TokenType.VAR_LITERAL && !String.isBlank(tokenByScheduleName.get(param.actualString)?.actualString);
                                    count += isValidNumber || isValidString || isValidVar ? 1 : 0;
                                }
                                paramStack.push(new Token(TokenType.NUMBER_LITERAL, String.valueOf(count)));
                            }
                            when 'rangelower' {
                                List<ConsumptionRate> rates = schedulesByName.get(paramStack.pop().actualString).ConsumptionRates;
                                Decimal value = decimalValue(paramStack.pop(), tokenByScheduleName);
                                Boolean done = false;
                                for (Integer i = 0; !done && i < rates.size(); i++) {
                                    ConsumptionRate rate = rates[i];
                                    if (isInBounds(value, rate)) {
                                        done = true;
                                        paramStack.push(new Token(TokenType.NUMBER_LITERAL, stringValue(rate.IPU_Lower_Bound__c)));
                                    }
                                }
                                if (!done) {
                                    // We never found a valid consumption rate
                                    paramStack.push(new Token(TokenType.NUMBER_LITERAL, '0'));
                                }
                            }
                            when 'rangeupper' {
                                List<ConsumptionRate> rates = schedulesByName.get(paramStack.pop().actualString).ConsumptionRates;
                                Decimal value = decimalValue(paramStack.pop(), tokenByScheduleName);
                                Boolean done = false;
                                for (Integer i = 0; !done && i < rates.size(); i++) {
                                    ConsumptionRate rate = rates[i];
                                    if (isInBounds(value, rate)) {
                                        done = true;
                                        paramStack.push(new Token(TokenType.NUMBER_LITERAL, stringValue(rate.IPU_Upper_Bound__c)));
                                    }
                                }
                                if (!done) {
                                    // We never found a valid consumption rate
                                    paramStack.push(new Token(TokenType.NUMBER_LITERAL, '0'));
                                }
                            }
                            when 'rangeoutput' {
                                List<ConsumptionRate> rates = schedulesByName.get(paramStack.pop().actualString).ConsumptionRates;
                                Decimal value = decimalValue(paramStack.pop(), tokenByScheduleName);
                                Boolean done = false;
                                for (Integer i = 0; !done && i < rates.size(); i++) {
                                    ConsumptionRate rate = rates[i];
                                    if (isInBounds(value, rate)) {
                                        done = true;
                                        paramStack.push(new Token(TokenType.NUMBER_LITERAL, stringValue(rate.Outcome__c)));
                                    }
                                }
                                if (!done) {
                                    // We never found a valid consumption rate
                                    paramStack.push(new Token(TokenType.NUMBER_LITERAL, '0'));
                                }
                            }
                            when 'progressiveoutcome' {
                                List<ConsumptionRate> rates = schedulesByName.get(paramStack.pop().actualString).ConsumptionRates;
                                Decimal value = decimalValue(paramStack.pop(), tokenByScheduleName);
                                Decimal amountRemaining = value;
                                Decimal result = 0;
                                Boolean done = false;
                                for (Integer i = 0; !done && i < rates.size(); i++) {
                                    ConsumptionRate rate = rates[i];
                                    if (isInBounds(value, rate)) {
                                        done = true;
                                        result += amountRemaining * rate.Outcome__c;
                                        paramStack.push(new Token(TokenType.NUMBER_LITERAL, stringValue(result)));
                                    } else if (value >= rate.IPU_Lower_Bound__c) {
                                        Decimal range = rate.IPU_Upper_Bound__c - rate.IPU_Lower_Bound__c;
                                        result += range * rate.Outcome__c;
                                        amountRemaining -= range;
                                    }
                                }
                                if (!done) {
                                    // We never found a valid consumption rate
                                    paramStack.push(new Token(TokenType.NUMBER_LITERAL, '0'));
                                }
                            }
                            when 'volumeoutcome' {
                                List<ConsumptionRate> rates = schedulesByName.get(paramStack.pop().actualString).ConsumptionRates;
                                Decimal value = decimalValue(paramStack.pop(), tokenByScheduleName);
                                Boolean done = false;
                                for (Integer i = 0; !done && i < rates.size(); i++) {
                                    ConsumptionRate rate = rates[i];
                                    if (isInBounds(value, rate)) {
                                        done = true;
                                        paramStack.push(new Token(TokenType.NUMBER_LITERAL, stringValue(value * rate.Outcome__c)));
                                    }
                                }
                                if (!done) {
                                    // We never found a valid consumption rate
                                    paramStack.push(new Token(TokenType.NUMBER_LITERAL, '0'));
                                }
                            }
                            when 'sumall' {

                                Decimal columnNumber = decimalValue(paramStack.pop().actualString);
                                String tableName = paramStack.pop().actualString;

                                if (!tokenByScheduleName.containsKey(tableName)) {
                                    continue;
                                }

                                // Find the table Token and access children list on the Token
                                Set<String> childrenNames = tokenByScheduleName.get(tableName).children;
                                Decimal sum = 0;

                                // Loop through children associated to Table
                                for (String childName : childrenNames ) {

                                    // Get up to date child token 
                                    List<Token> tokenList = tokenListByScheduleName.get(childName);

                                    // Return list of tokens associated to child
                                    for (Token outputToken : tokenList) {

                                        if (outputToken.columnNumber == columnNumber) {   
                                            Decimal value = decimalValue(outputToken.actualString);
                                            sum = value != null ? sum + value : sum;
                                        }
                                    }
                                }

                                paramStack.push(new Token(TokenType.NUMBER_LITERAL, stringValue(sum)));
                            } 
                            when 'min' {

                                Decimal columnNumber = decimalValue(paramStack.pop().actualString);
                                String tableName = paramStack.pop().actualString;

                                if (!tokenByScheduleName.containsKey(tableName)) {
                                    continue;
                                }

                                Set<String> childrenNames = tokenByScheduleName.get(tableName).children;
                                
                                Decimal minValue;

                                // Loop through children associated to Table
                                for (String childName : childrenNames ) {
                                    for (Token outputToken : tokenListByScheduleName.get(childName)) {
                                        if (outputToken.columnNumber == columnNumber) {   
                                            Decimal value = decimalValue(outputToken.actualString);
                                            if (value != null) {
                                                if (minValue == null) {
                                                    minValue = value;
                                                } else if (value < minValue) {
                                                    minValue = value;
                                                }
                                            }
                                        }
                                    }
                                }  

                                if (minValue == null) {
                                    paramStack.push(new Token(TokenType.NUMBER_LITERAL, '0'));
                                } else {
                                    paramStack.push(new Token(TokenType.NUMBER_LITERAL, stringValue(minValue)));
                                }
                            } 
                            when 'max' {

                                Decimal columnNumber = decimalValue(paramStack.pop().actualString);
                                String tableName = paramStack.pop().actualString;

                                if (!tokenByScheduleName.containsKey(tableName)) {
                                    continue;
                                }

                                Set<String> childrenNames = tokenByScheduleName.get(tableName).children;
                                
                                Decimal maxValue = 0;

                                // Loop through children associated to Table
                                for (String childName : childrenNames ) {
                                    for (Token outputToken : tokenListByScheduleName.get(childName)) {
                                        if (outputToken.columnNumber == columnNumber) {   
                                            Decimal value = decimalValue(outputToken.actualString);
                                            if (value != null && value > maxValue) {
                                                maxValue = value;
                                            }
                                        }
                                    }
                                }  

                                paramStack.push(new Token(TokenType.NUMBER_LITERAL, stringValue(maxValue)));  
                            } 
                            when 'average' {
                                
                                Decimal columnNumber = decimalValue(paramStack.pop().actualString);
                                String tableName = paramStack.pop().actualString;

                                if (!tokenByScheduleName.containsKey(tableName)) {
                                    continue;
                                }

                                Set<String> childrenNames = tokenByScheduleName.get(tableName).children;
                                
                                Integer count = 0;
                                Decimal sum = 0;
                                
                                // Loop through children associated to Table
                                for (String childName : childrenNames ) {
                                    for (Token outputToken : tokenListByScheduleName.get(childName)) {
                                        if (outputToken.columnNumber == columnNumber) {   
                                            count++;
                                            Decimal value = decimalValue(outputToken.actualString);
                                            if (value != null) {
                                                sum = value != null ? sum + value : sum;
                                            }
                                        }
                                    }
                                }  

                                if (sum > 0 && count > 0) {
                                    Decimal average = sum/count;
                                    paramStack.push(new Token(TokenType.NUMBER_LITERAL, stringValue(average)));
                                } else {
                                    paramStack.push(new Token(TokenType.NUMBER_LITERAL, '0'));
                                }
                            } 
                            when 'countcolumn' {

                                Decimal columnNumber = decimalValue(paramStack.pop().actualString);
                                String tableName = paramStack.pop().actualString;

                                if (!tokenByScheduleName.containsKey(tableName)) {
                                    continue;
                                }

                                Set<String> childrenNames = tokenByScheduleName.get(tableName).children;
                                
                                Integer count = 0;
                                
                                // Loop through children associated to Table
                                for (String childName : childrenNames ) {
                                    for (Token outputToken : tokenListByScheduleName.get(childName)) {
                                        if (outputToken.columnNumber == columnNumber) {   
                                            count++;
                                        }
                                    }
                                }  

                                paramStack.push(new Token(TokenType.NUMBER_LITERAL, stringValue(count)));
                            } 
                            when 'counta' {

                                Decimal columnNumber = decimalValue(paramStack.pop().actualString);
                                String tableName = paramStack.pop().actualString;

                                if (!tokenByScheduleName.containsKey(tableName)) {
                                    continue;
                                }

                                Set<String> childrenNames = tokenByScheduleName.get(tableName).children;
                                
                                Integer count = 0;
                                
                                // Loop through children associated to Table
                                for (String childName : childrenNames ) {
                                    for (Token outputToken : tokenListByScheduleName.get(childName)) {
                                        if (outputToken.columnNumber == columnNumber) {   
                                            if (outputToken.actualString != null) {
                                                count++;

                                            }
                                        }
                                    }
                                }  
                                
                                paramStack.push(new Token(TokenType.NUMBER_LITERAL, stringValue(count)));   
                            } 
                            //T14064
                            when 'round' {
                                Integer numOfDigits = Integer.valueOf(paramStack.pop().actualString);
                                Decimal actNumber = decimalValue(paramStack.pop().actualString);
                                
								Decimal dem = actNumber?.setScale(numOfDigits == NULL ? 0 : numOfDigits ) ;
                 
                                paramStack.push(new Token(TokenType.NUMBER_LITERAL, stringValue(dem)));
                            }
                            when 'ceil' {
                                Integer numOfDigits = Integer.valueOf(paramStack.pop().actualString);
                                Decimal actNumber = decimalValue(paramStack.pop().actualString);
                                
                                Decimal dem = actNumber.setScale((numOfDigits == NULL ? 0 :numOfDigits),System.RoundingMode.UP);
                                
                                paramStack.push(new Token(TokenType.NUMBER_LITERAL, stringValue(dem)));
                            }
                            when 'floor' {
								Integer numOfDigits = Integer.valueOf(paramStack.pop().actualString);
                                Decimal actNumber = decimalValue(paramStack.pop().actualString);
                                
                                Decimal dem = actNumber.setScale((numOfDigits == NULL ? 0 :numOfDigits),System.RoundingMode.DOWN);
                                
                                paramStack.push(new Token(TokenType.NUMBER_LITERAL, stringValue(dem)));
                            }
                            //T14064
                            // Shouldn't ever be anything else
                            // when else {} 
                        }
                    }
                }
            }

            Decimal decimalAnswer = decimalValue(paramStack.pop(), tokenByScheduleName);
            decimalAnswer = decimalAnswer == null ? 0 : decimalAnswer.round(RoundingMode.CEILING);
            returnMap.put(uniqueKey, decimalAnswer);

        }

        return returnMap;

    }

    public class EvaluationException extends Exception {}

    // Wrapper around OOTB string-to-decimal converter to gracefully handle null
    private static Decimal decimalValue(String s) {
        if (String.isBlank(s)) {
            return null;
        }
        return Decimal.valueOf(s);
    }

    // Wrapper around the above wrapper to gracefully handle numbers and variables
    private static Decimal decimalValue(Token t, Map<String, Token> variables) {
        if (t == null) {
            return null;
        } else if (t.type == TokenType.NUMBER_LITERAL) {
            return decimalValue(t.actualString);
        } else if (t.type == TokenType.VAR_LITERAL) {
            return decimalValue(variables.get(t.actualString)?.actualString);
        } else {
            throw new EvaluationException('Invalid parameter to function');
        }
    }

    // Wrapper around the above wrapper to allow for values of type String and Decimal
    private static Object objectValue(Token t, Map<String, Token> variables) {
        if (t == null) {
            return null;
        } else if (t.type == TokenType.NUMBER_LITERAL) {
            return decimalValue(t.actualString);
        } else if (t.type == TokenType.STRING_LITERAL) {
            return t.actualString;
        } else if (t.type == TokenType.VAR_LITERAL) {
            // If it's a variable, check the type of the value it refers to before returning
            Token valToken = variables.get(t.actualString);
            if (valToken == null) {
                return null;
            } else if (valToken.type == TokenType.STRING_LITERAL) {
                return valToken.actualString;
            } else if (valToken.type == TokenType.NUMBER_LITERAL) {
                return decimalValue(valToken.actualString);
            } else {
                return null;
            }
        } else {
            return null;
        }
    }

    // Wrapper around OOTB string converter to gracefully handle null
    private static String stringValue(Object o) {
        if (o == null) {
            return null;
        }
        return String.valueOf(o);
    }

    // Utility method to determine whether a given value falls into the range of a given consumption schedule
    private static Boolean isInBounds(Decimal value, ConsumptionRate rate) {
        return value >= rate.IPU_Lower_Bound__c && (rate.IPU_Upper_Bound__c == null || value <= rate.IPU_Upper_Bound__c);
    }

    private static Boolean isRangeFunction(Token t) {
        return rangeFunctions.contains(t.actualString);
    }

    private static final Set<String> rangeFunctions = new Set<String> {
        'rangelower',
        'rangeupper',
        'rangeoutput',
        'volumeoutcome',
        'progressiveoutcome',
        'round', //T14064
        'ceil',
        'floor'
    };

    public static Boolean containsTableFunction(String function) {
        
        for (String tableFunction : tableFunctions) {
            if (function.contains(tableFunction + '(')) {
                return true;
            }
        }
        return false;
    }

    private static Boolean isTableFunction(Token t) {
        return tableFunctions.contains(t.actualString);
    }

    private static final Set<String> tableFunctions = new Set<String> {
        'sumall',
        'min',
        'max',
        'average',
        'countcolumn',
        'counta'
    };

    ////////////////////////////////////////////////////////
    // Shared utilities
    ////////////////////////////////////////////////////////

    // Represents a single element in a formula for ease of use
    // Each token has a type and a value
    private class Token {
        public TokenType type;
        public String actualString;
        public String key;
        public Decimal rowNumber;
        public Decimal columnNumber; 
        public Set<String> children = new Set<String>();

        public Token(TokenType type, String actualString) {
            this.type = type;
            this.actualString = actualString;
        }
        public override String toString() {
            return '[' + type + ',' + actualString + ']';
        }
    }

    private enum TokenType {
        VAR_LITERAL,
        NUMBER_LITERAL,
        STRING_LITERAL,
        PLUS,
        MINUS,
        TIMES,
        DIVIDE,
        LESS_THAN,
        LESS_THAN_EQUAL,
        GREATER_THAN,
        GREATER_THAN_EQUAL,
        EQUALS,
        LPAREN,
        RPAREN,
        FUNCTION,
        COMMA
    }

    // TODO: Convert these next 2 maps to metadata types, and query/call access methods to get those
    private static final Map<TokenType, Integer> operatorPrecedence = new Map<TokenType, Integer> {
        TokenType.PLUS => 2,
        TokenType.MINUS => 2,
        TokenType.TIMES => 3,
        TokenType.DIVIDE => 3,
        TokenType.LESS_THAN => 1,
        TokenType.GREATER_THAN => 1,
        TokenType.LESS_THAN_EQUAL => 1,
        TokenType.GREATER_THAN_EQUAL => 1,
        TokenType.EQUALS => 1,
        TokenType.COMMA => 0,
        TokenType.LPAREN => -1
    };

    // -1 encodes variable number of parameters
    // May be replaced with a metadata type in the future
    private static final Map<String, Integer> functionNamesToParamCounts = new Map<String, Integer> {
        'count' => -1,
        'if' => 3,
        'rangeupper' => 2,
        'rangelower' => 2,
        'rangeoutput' => 2,
        'progressiveoutcome' => 2,
        'volumeoutcome' => 2,
        'sumall' => 2,
        'min' => 2,
        'max' => 2,
        'average' => 2,
        'countcolumn' => 2,
        'counta' => 2,
        'round' => 2,
        'floor' => 2,
        'ceil' => 2
    };

    // Quick stack implementation using List as an underlying data structure
    private class TokenStack {
        private List<Token> stack = new List<Token>();
        private Integer currentIndex = -1;

        // Adds a token to the top of the stack
        public void push(Token t) {
            currentIndex++;
            if (currentIndex < stack.size()) {
                stack.set(currentIndex, t);
            } else {
                stack.add(t);
            }
        }

        // Removes the top element of the stack and returns it
        public Token pop() {
            if (currentIndex >= 0) {
                Token t = stack[currentIndex];
                currentIndex--;
                return t;
            } else {
                return null;
            }
        }

        // Returns the top element of the stack without removing it
        public Token peek() {
            if (currentIndex >= 0) {
                return stack[currentIndex];
            } else {
                return null;
            }
        }

        // Returns true if the stack currently has no elements
        public Boolean isEmpty() {
            return currentIndex == -1;
        }

        public override String toString() {
            String acc = '';
            for (Integer index = 0; index <= currentIndex; index++) {
                acc += stack[index].actualString + (index == currentIndex? '' : delimiter);
            }
            return acc;
        }
    }

}