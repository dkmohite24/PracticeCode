public class Calculator {
    @AuraEnabled
    public static decimal calculateSum(decimal fnumber, decimal Snumber){
        decimal sum =fnumber+Snumber;
         system.debug('+');
        return sum;
    }
    @AuraEnabled
    public static decimal calculateSub(decimal fnumber, decimal Snumber){
        decimal sum =fnumber-Snumber;
        system.debug('negetive');
        return sum;
    }
    @AuraEnabled
    public static decimal calculateMult(decimal fnumber, decimal Snumber){
        decimal sum =fnumber*Snumber;
        return sum;
    }
    @AuraEnabled
    public static decimal calculateDiv(decimal fnumber, decimal Snumber){
        decimal sum =fnumber/Snumber;
        return sum;
    }

}