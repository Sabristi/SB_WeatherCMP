public class WeatherReportCacheHandler {
    private Cache.OrgPartition part;

    public WeatherReportCacheHandler() {
        part = new Cache.OrgPartition('local.WeatherReport');
    }

    public void putSendingDate(String sendingDate) {
        if(part != null){
           part.put('lastOrgSendingReportDate', sendingDate); 
        }
    }

    public String getLastSendingDate() {
        String lastSendingDate = (String)part.get('lastOrgSendingReportDate');

        if (lastSendingDate != null) {
            return lastSendingDate;
        }else{
            return 'None';
        }
    }
}