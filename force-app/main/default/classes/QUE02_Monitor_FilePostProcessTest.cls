@isTest
public class QUE02_Monitor_FilePostProcessTest {

    @isTest
    static void testMonitor_FilePostProcessTest() {
        QUE02_Monitor_FilePostProcess testQueuable = new QUE02_Monitor_FilePostProcess();

        Test.startTest();
            
            SchedulableContext sc = null;
            testQueuable.execute(sc);
        Test.stopTest();
    }
}