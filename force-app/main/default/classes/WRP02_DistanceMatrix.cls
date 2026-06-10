public with sharing class WRP02_DistanceMatrix {
    @AuraEnabled
    public List<String> destination_addresses;
    @AuraEnabled
    public List<String> origin_addresses;
    @AuraEnabled
    public List<Row> rows;
    @AuraEnabled
    public String status;

    public class Row{
        @AuraEnabled
        public List<Element> elements;
    }

    public class Element{
        @AuraEnabled
        public TextValue distance;
        @AuraEnabled
        public TextValue duration;
        @AuraEnabled
        public String status;
    }

    public class TextValue{
        @AuraEnabled
        public String text;
        @AuraEnabled
        public String value;
    }

    public static WRP02_DistanceMatrix parse(String json) {
		return (WRP02_DistanceMatrix) System.JSON.deserialize(json, WRP02_DistanceMatrix.class);
	}
}