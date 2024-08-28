@IsTest
public class CasesTriggerHandlerTest {
    @IsTest
    static void testEmptyCaseCreate() {
        Case record = new Case();
        try {
            insert record;
            System.assert(true,'Case record created successfully');
        } catch (Exception e) {
            System.assert(false,'Case record expected to be created');
        }
    }
}