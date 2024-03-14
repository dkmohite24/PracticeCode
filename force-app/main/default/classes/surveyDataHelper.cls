public class surveyDataHelper {
    public static void updateScore(List<Survey_Data__c> newList) {
        for(Survey_Data__c survey : newList) {
            if(survey.Date_Taken__c.year() >= 2021) {
                calculateSurvey2021(survey);
            }
            else {
                calculateSurvey2020(survey);
            }
            
        }
    }
    
    private static void calculateSurvey2021(Survey_Data__c survey) {
        Integer groupBCount = 0;
        Decimal groupBSum = 0.0;
        Decimal surveyScore = 0.0;
        
        if(survey.Survey_Type__c == 'Parts') {
            if(survey.Q2_Value__c != null && survey.Q2_Value__c != 0) {
                groupBSum += survey.Q2_Value__c;
                groupBCount++;
            }
            if(survey.Q3_Value__c != null && survey.Q3_Value__c != 0) {
                groupBSum += survey.Q3_Value__c;
                groupBCount++;
            }
            Decimal groupBAvg = groupBCount != 0 ? groupBSum/groupBCount : 0;
            groupBAvg = groupBAvg.setScale(1,System.RoundingMode.HALF_UP);
            if(survey.Q1_Value__c != null && survey.Q1_Value__c != 0) {
                surveyScore = groupBAvg != 0 ? (groupBAvg + survey.Q1_Value__c)/2 : survey.Q1_Value__c;
            }
            else {
                surveyScore = groupBAvg;
                survey.Old_Formula__c = true;
            }
            if(groupBCount != 2) survey.Old_Formula__c = true;
        }
        else if(survey.Survey_Type__c == 'Service') {
            if(survey.Q2_Value__c != null && survey.Q2_Value__c != 0) {
                groupBSum += survey.Q2_Value__c;
                groupBCount++;
            }
            if(survey.Q3_Value__c != null && survey.Q3_Value__c != 0) {
                groupBSum += survey.Q3_Value__c;
                groupBCount++;
            }
            Decimal groupBAvg = groupBCount != 0 ? groupBSum/groupBCount : 0;
            groupBAvg = groupBAvg.setScale(1,System.RoundingMode.HALF_UP);
            if(survey.Q1_Value__c != null && survey.Q1_Value__c != 0) {
                surveyScore = groupBAvg != 0 ? (groupBAvg + survey.Q1_Value__c)/2 : survey.Q1_Value__c;
            }
            else {
                surveyScore = groupBAvg;
                survey.Old_Formula__c = true;
            }
            if(groupBCount != 2) survey.Old_Formula__c = true;
            
        }
        else if(survey.Survey_Type__c == 'CSI') {
            if(survey.Q2_Value__c != null && survey.Q2_Value__c != 0) {
                groupBSum += survey.Q2_Value__c;
                groupBCount++;
            }
            if(survey.Q3_Value__c != null && survey.Q3_Value__c != 0) {
                groupBSum += survey.Q3_Value__c;
                groupBCount++;
            }
            Decimal groupBAvg = groupBCount != 0 ? groupBSum/groupBCount : 0;
            groupBAvg = groupBAvg.setScale(1,System.RoundingMode.HALF_UP);
            if(survey.Q1_Value__c != null && survey.Q1_Value__c != 0) {
                surveyScore = groupBAvg != 0 ? (groupBAvg + survey.Q1_Value__c)/2 : survey.Q1_Value__c;
            }
            else {
                surveyScore = groupBAvg;
                survey.Old_Formula__c = true;
            }
            if(groupBCount != 2) survey.Old_Formula__c = true;
            
        }
        survey.Survey_Score__c =  surveyScore;
    }
    private static void calculateSurvey2020(Survey_Data__c survey) {
        Integer groupBCount = 0;
        Decimal groupBSum = 0.0;
        Decimal surveyScore = 0.0;
        
        if(survey.Survey_Type__c == 'Parts') {
            if(survey.Q4_Value__c != null && survey.Q4_Value__c != 0) {
                groupBSum += survey.Q4_Value__c;
                groupBCount++;
            }
            if(survey.Q8_Value__c != null && survey.Q8_Value__c != 0) {
                groupBSum += survey.Q8_Value__c;
                groupBCount++;
            }
            if(survey.Q9_Value__c != null && survey.Q9_Value__c != 0) {
                groupBSum += survey.Q9_Value__c;
                groupBCount++;
            }
            Decimal groupBAvg = groupBCount != 0 ? groupBSum/groupBCount : 0;
            groupBAvg = groupBAvg.setScale(1,System.RoundingMode.HALF_UP);
            if(survey.Q1_Value__c != null && survey.Q1_Value__c != 0) {
                surveyScore = groupBAvg != 0 ? (groupBAvg + survey.Q1_Value__c)/2 : survey.Q1_Value__c;
            }
            else {
                surveyScore = groupBAvg;
                survey.Old_Formula__c = true;
            }
            if(groupBCount != 3) survey.Old_Formula__c = true;
        }
        else if(survey.Survey_Type__c == 'Service') {
            if(survey.Q4_Value__c != null && survey.Q4_Value__c != 0) {
                groupBSum += survey.Q4_Value__c;
                groupBCount++;
            }
            if(survey.Q8_Value__c != null && survey.Q8_Value__c != 0) {
                groupBSum += survey.Q8_Value__c;
                groupBCount++;
            }
            if(survey.Q10_Value__c != null && survey.Q10_Value__c != 0) {
                groupBSum += survey.Q10_Value__c;
                groupBCount++;
            }
            Decimal groupBAvg = groupBCount != 0 ? groupBSum/groupBCount : 0;
            groupBAvg = groupBAvg.setScale(1,System.RoundingMode.HALF_UP);
            if(survey.Q1_Value__c != null && survey.Q1_Value__c != 0) {
                surveyScore = groupBAvg != 0 ? (groupBAvg + survey.Q1_Value__c)/2 : survey.Q1_Value__c;
            }
            else {
                surveyScore = groupBAvg;
                survey.Old_Formula__c = true;
            }
            if(groupBCount != 3) survey.Old_Formula__c = true;
            
        }
        else if(survey.Survey_Type__c == 'CSI') {
            if(survey.Q6_Value__c != null && survey.Q6_Value__c != 0) {
                groupBSum += survey.Q6_Value__c;
                groupBCount++;
            }
            if(survey.Q8_Value__c != null && survey.Q8_Value__c != 0) {
                groupBSum += survey.Q8_Value__c;
                groupBCount++;
            }
            if(survey.Q9_Value__c != null && survey.Q9_Value__c != 0) {
                groupBSum += survey.Q9_Value__c;
                groupBCount++;
            }
            Decimal groupBAvg = groupBCount != 0 ? groupBSum/groupBCount : 0;
            groupBAvg = groupBAvg.setScale(1,System.RoundingMode.HALF_UP);
            if(survey.Q1_Value__c != null && survey.Q1_Value__c != 0) {
                surveyScore = groupBAvg != 0 ? (groupBAvg + survey.Q1_Value__c)/2 : survey.Q1_Value__c;
            }
            else {
                surveyScore = groupBAvg;
                survey.Old_Formula__c = true;
            }
            if(groupBCount != 3) survey.Old_Formula__c = true;
            
        }
        survey.Survey_Score__c =  surveyScore;
    }
}