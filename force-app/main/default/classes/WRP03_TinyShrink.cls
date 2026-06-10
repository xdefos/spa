public with sharing class WRP03_TinyShrink {
    public Content input;
    public Content output;

    public class Content{
        public Integer size;
        public String type;
        public Integer width;
        public Integer height;
        public Double ratio;
        public String url;
        
    }

    public static WRP03_TinyShrink parse(String json) {
		return (WRP03_TinyShrink) System.JSON.deserialize(json, WRP03_TinyShrink.class);
	}
}