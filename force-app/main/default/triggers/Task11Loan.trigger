trigger Task11Loan on Case (After insert, After update ) {
    if(trigger.isafter && trigger.isinsert){
        LoanStatus kk = new LoanStatus();
        kk.LoanStatusMeth(trigger.new);
    }

}