public class AttachmentDropzoneController {
    
    @AuraEnabled(cacheable=true)
    public static String getAllAttachments(Id recordId) {
        
        List<Product_Content__c> pcList = [SELECT Id, Type__c, Order__c, Attachment_Filename__c, Video_Link_Embed_URL__c, Attachment_View_URL__c FROM Product_Content__c WHERE Product__c = :recordId ORDER BY Order__c];
        
        List<Result> results = new List<Result>();
        for(Product_Content__c pc : pcList) {
            Result r = new Result();
            r.content = pc;
            if(pc.Type__c == 'Image') r.isImage = true;
            else if(pc.Type__c == 'Document') r.isDocument = true;
            else if(pc.Type__c == 'Video') r.isVideo = true;
            
            results.add(r);
        }
        
        return JSON.serialize(results);
        
    }
    
    public class Result {
        
        public Boolean isImage;
        public Boolean isVideo;
        public Boolean isDocument;
        public Product_Content__c content;
        
    }
    
    
    @AuraEnabled
    public static Attachment getContent(Id parentId) {

        // Attachment permissions are set in parent object
        if (!Schema.sObjectType.Product_Content__c.isAccessible()) {
            throw new System.NoAccessException();
            // return null;
        }
 
        Product_Content__c pc = [SELECT Id, Attachment_Id__c FROM Product_Content__c WHERE Id=:parentId];
        return [SELECT Id, Name, LastModifiedDate, ContentType FROM Attachment 
            WHERE parentid=:ParentId AND Id=:pc.Attachment_Id__c];
    }
    
    @AuraEnabled
    public static Id saveAttachment(Id parentId, String fileName, String base64Data, String contentType) { 

        // Edit permission on parent object is required to add attachments
        if (!Schema.sObjectType.Product_Content__c.isUpdateable()) {
            throw new System.NoAccessException();
        }
        
        List<Attachment> oldattachments = [SELECT Id FROM Attachment WHERE parentid=:ParentId];
        if(oldattachments.size() > 0) delete(oldattachments);
        
        Attachment attachment = new Attachment();
        attachment.parentId = parentId;
        attachment.body = EncodingUtil.base64Decode(base64Data);
        attachment.name = fileName;
        attachment.contentType = contentType;
        insert attachment;
                
        Product_Content__c pc = [SELECT Id FROM Product_Content__c WHERE Id=:parentId];
        pc.Attachment_Id__c = attachment.Id;
        pc.Attachment_Filename__c = filename;
        pc.Domain_URL__c = URL.getOrgDomainUrl().toExternalForm();
        update(pc);

        return attachment.id;
    }
    
}