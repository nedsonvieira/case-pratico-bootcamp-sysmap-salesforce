public with sharing class ResponseDto {
    
    private Datetime createdDate;
    private Datetime slaDeadline;
    private String status;
    private Boolean slaMet;
    private Datetime timeClosed;
    
    public ResponseDto(Datetime createdDate, Datetime slaDeadline, String status, Boolean slaMet, Datetime timeClosed) {
        this.createdDate = createdDate;
        this.slaDeadline = slaDeadline;
        this.status = status;
        this.slaMet = slaMet;
        this.timeClosed = timeClosed;
    }
}