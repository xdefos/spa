// l'éxécution doit se faire par le créateur de l'Org : Philippe Defossez
// System.schedule('Monitor FilePostProcess Hourly', '0 0 * * * ?', new QUE02_Monitor_FilePostProcess() );


public with sharing class QUE02_Monitor_FilePostProcess implements Schedulable {

    Integer delayInMinutes = 1;
    @testVisible
    private static Boolean doChainJob = true;

    public QUE02_Monitor_FilePostProcess() {}

    public void execute(SchedulableContext context) {     
        List<AsyncApexJob> lQueuable = [SELECT ApexClass.Name, Status FROM AsyncApexJob where ApexClass.Name ='QUE01_FilePostProcess' AND Status IN ('Processing','Queued')];
        System.debug('lQueuable: ' + lQueuable);
        if (lQueuable.isEmpty() && !Test.isRunningTest())
            System.enqueueJob(new QUE01_FilePostProcess(),5);        
    }
}