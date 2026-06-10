public class UTI02_ObjectCompare implements Comparable {

    public Object record;
    public String fieldName;

    // Constructor
    public UTI02_ObjectCompare(Object inputRecord, String inputFieldName) {
        record = inputRecord;
        fieldName = inputFieldName;
    }

    public Integer compareTo(Object compareTo) {
        String recordJson = Json.serialize(record);
        Map<String, Object> recordInstance = (Map<String, Object>)JSON.deserializeUntyped(recordJson);

        String compareToJson = Json.serialize(compareTo);
        Map<String, Object> compareInstance = (Map<String, Object>)JSON.deserializeUntyped(compareToJson);

        Integer returnValue = 0;
        if ((Double)recordInstance.get(fieldName) > (Double)compareInstance.get(fieldName)) {
            returnValue = 1;
        } else if ((Double)recordInstance.get(fieldName) < (Double)compareInstance.get(fieldName)) {
            returnValue = -1;
        }

        return returnValue;
    }
}